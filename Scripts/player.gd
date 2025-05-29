extends CharacterBody2D
class_name Player

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

@export_range(500.0, 1500.0) var throw_power: float = 800.0
@export_range(500, 2500.0) var shadow_jump_strength: float = 1000.0

@onready var right_shoulder_pos: Marker2D = $RightShoulderPos
@onready var left_shoulder_pos: Marker2D = $LeftShoulderPos

@onready var light_ray: RayCast2D = $LightRay
@onready var hand: Node2D = $Hand
@onready var hold_spot: Marker2D = $Hand/HoldSpot
@onready var hand_sprite: Sprite2D = $Hand/HandSprite

@onready var trajectory_line: Line2D = $TrajectoryLine

@onready var grab_cast_top: RayCast2D = $GrabCastTop
@onready var grab_cast_right: RayCast2D = $GrabCastRight
@onready var grab_cast_left: RayCast2D = $GrabCastLeft
@onready var grab_cast_down: RayCast2D = $GrabCastDown
@onready var shadow_shot_ground_cast: RayCast2D = $ShadowShotGroundCast
@onready var melee_cast: RayCast2D = $MeleeCast

@onready var collision_shape: CollisionShape2D = $CollisionShape
@onready var shadow_collision = $ShadowCollisionShape

@onready var grab_rays = [grab_cast_top, grab_cast_right, grab_cast_left]
@onready var melee_hit_box: Area2D = $MeleeHitBox

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var just_jumped := false

var carried_weapon: Weapon = null

var health = 2

enum States {
	IDLE,
	AIM,
	MELEE,
	WALK,
	FALL,
	DUCT,
	SHADOW_MELD,
	EXIT_SHADOW_MELD,
	PREP_SHADOW_SHOT,
	SHADOW_SHOT,
	GRAB,
	DAMAGE,
	DEAD
}

enum Facing { RIGHT, LEFT }

var last_state: States
var state: States
var facing : Facing
var idle_hand_rotation: float

func _ready():
	PlayerManager.player = self
	
	set_state(States.IDLE)
	set_facing(Facing.RIGHT)

func _process(_delta: float) -> void:
	if health <= 0:
		set_state(States.DEAD)
		
	if PlayerManager.is_aiming:
		hand.look_at(get_global_mouse_position())
	
	if PlayerManager.scanning_light:
		var dir_to_light = global_position.distance_to(PlayerManager.light_target.global_position)
		light_ray.enabled = true
		light_ray.target_position.x = dir_to_light
		light_ray.look_at(PlayerManager.light_target.light_pos_marker.global_position)
		light_ray.force_raycast_update()
		
		if light_ray.is_colliding():
			## Debug marker spawn
			#var col_pos = light_ray.get_collision_point()
			#var instance = preload("res://Scenes/collision_marker.tscn").instantiate()
			#instance.global_position = col_pos
			#get_tree().root.add_child(instance)
			
			PlayerManager.set_in_shadow(true)
			#print("In Shadows!")
		else:
			light_ray.enabled = false
			PlayerManager.set_in_shadow(false)
			#print("In Light!")
	
func _physics_process(delta: float) -> void:
	# Add the gravity based on state.
	if not is_on_floor():
		if state in [States.WALK, States.SHADOW_SHOT, States.DEAD, States.FALL, States.DAMAGE]:
			velocity += get_gravity() * (delta * 2)
		if state in [States.DUCT]:
			velocity = velocity.lerp(Vector2.ZERO, delta)
	
	handle_facing()
	handle_states(delta)
	handle_interactions()
	
	move_and_slide()

func handle_facing() -> void:
	match facing:
		Facing.RIGHT:
			if carried_weapon:
				carried_weapon.flip_weapon()
			
			if grab_cast_left.is_colliding():
				melee_hit_box.monitoring = false
			else:
				melee_hit_box.monitoring = true
		Facing.LEFT:
			if carried_weapon:
				carried_weapon.flip_weapon()
			
			if grab_cast_left.is_colliding():
				melee_hit_box.monitoring = false
			else:
				melee_hit_box.monitoring = true

func set_facing(new_facing) -> void:
	if new_facing != facing:
		facing = new_facing
		
	match facing:
		Facing.LEFT:
			idle_hand_rotation = 108
			melee_hit_box.position = $HitBoxPosLeft.position
			hand.position = left_shoulder_pos.position
			hand.rotation_degrees = idle_hand_rotation
			animated_sprite.flip_h = true
			
		Facing.RIGHT:
			idle_hand_rotation = 72
			melee_hit_box.position = $HitBoxPosRight.position
			hand.position = right_shoulder_pos.position
			hand.rotation_degrees = idle_hand_rotation
			
			animated_sprite.flip_h = false

func set_state(new_state: States):
	if state not in [States.SHADOW_MELD]:
		set_collision_mask_value(5, 1)
	
	if state in [States.SHADOW_SHOT, States.SHADOW_MELD]:
		#grab_cast_down.enabled = true
		ground_check()
		#grab_cast_down.enabled = false
	
	if state in [States.SHADOW_SHOT, States.SHADOW_MELD]:
		if new_state in [States.IDLE, States.EXIT_SHADOW_MELD]:
			ceiling_check()
			
	if new_state in [States.IDLE, States.WALK]:
		hand_sprite.visible = false
	
	if new_state not in [States.WALK]:
		match facing:
			Facing.RIGHT:
				animation_player.play("idle_hand_R")
			Facing.LEFT:
				animation_player.play("idle_hand_L")
	
	last_state = state
	if state != new_state:
		match new_state:
			States.DEAD:
				if carried_weapon:
					carried_weapon.drop_weapon()
					
				animated_sprite.play("dead")
				hand_sprite.visible = false
				PlayerManager.is_player_dead = true
			
			States.DAMAGE:
				var blood_spatter = preload("res://Scenes/FX/black_blood_spatter.tscn").instantiate()
				blood_spatter.global_position = global_position
				get_tree().get_first_node_in_group("BackWall").add_child(blood_spatter)
				animated_sprite.play("damage")
				# State switch on animation_finished
			
			States.IDLE:
				animated_sprite.play("idle")
				collision_shape.disabled = false
				#shadow_collision.disabled = true
				
			States.WALK:
				if shadow_shot_ground_cast.is_colliding():
					ground_check()
				
				match facing:
					Facing.RIGHT:
						set_facing(Facing.RIGHT)
					
					Facing.LEFT:
						set_facing(Facing.LEFT)
					
				animated_sprite.play("walk")
			
			States.SHADOW_MELD:
				if hand_sprite.visible:
					hand_sprite.visible = false
				var inside_area: Area2D = get_tree().get_first_node_in_group("Indoors")
				var overlaps = inside_area.get_overlapping_bodies()
				#print(overlaps)
				if state != States.SHADOW_MELD and overlaps.is_empty():
					set_state(States.IDLE)
					return
				
				#print("Shadowmeld: ENGAGE")
				set_collision_mask_value(5, 0)
				collision_shape.disabled = true
				PlayerManager.is_inside = true
				#shadow_collision.disabled = false
				
				if state == States.SHADOW_SHOT:
					#animated_sprite.play("shadow_shape")
					return
					
				animated_sprite.play("shadow_meld")
			
			States.EXIT_SHADOW_MELD:
				velocity = Vector2.ZERO
				animated_sprite.play("exit_shadow_meld")
				pass
			
			States.PREP_SHADOW_SHOT:
				animated_sprite.play("prep_jump")
			
			States.SHADOW_SHOT:
				#print("SHOT!")
				Audio.play("res://Audio/FX/cloth3.ogg", -10)
				if !PlayerManager.is_in_shadow:
					set_state(States.EXIT_SHADOW_MELD)
					
				collision_shape.disabled = true
				#shadow_collision.disabled = false
				animated_sprite.play("shadow_shape")
			
			States.MELEE:
				if carried_weapon:
					match carried_weapon.weapon_type:
						"melee":
							carried_weapon.visible = false
							animated_sprite.play("melee_knife")
						"ranged":
							animated_sprite.play("melee")
				else:
					animated_sprite.play("melee")
			
			States.GRAB:
				collision_shape.disabled = false
				hand_sprite.visible = true
				#shadow_collision.disabled = true
				for ray in [grab_cast_left, grab_cast_right]:
					if ray.is_colliding():
						animated_sprite.play("grab_wall")
				if grab_cast_top.is_colliding():
					animated_sprite.play("grab_ceiling")
				#animated_sprite.play("idle")
			
			States.AIM:
				hand_sprite.visible = true
				for ray in grab_rays:
					if ray.is_colliding():
						return
				animated_sprite.play("aim")
			
			States.FALL:
				animated_sprite.play("fall")
	
	state = new_state

func handle_states(delta) -> void:
	if PlayerManager.game_complete:
		set_state(States.IDLE)
		velocity.x = 0
		return
	
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	match state:
		States.IDLE:
			if direction.x:
				set_state(States.WALK)
			if !is_on_floor():
				set_state(States.FALL)
			velocity.x = 0
		
		States.FALL:
			if is_on_floor():
				#print("Landed!")
				set_state(States.IDLE)
			
			if grab_cast_down.is_colliding():
				ground_check()
		
		States.DAMAGE:
			velocity.x = 0
		
		States.WALK:
			if velocity.y < 0:
				set_state(States.FALL)
				
			if direction.x:
				velocity.x = direction.x * SPEED
			else:
				set_state(States.IDLE)
			
			if direction.x < 0:
				set_facing(Facing.LEFT)
				animation_player.play("walk_hand_L")
			elif direction.x > 0:
				set_facing(Facing.RIGHT)
				animation_player.play("walk_hand_R")
		
		States.MELEE:
			velocity.x = 0
		
		States.AIM:
			velocity.x = 0
			hand.look_at(get_global_mouse_position())
		
		States.SHADOW_MELD:
			if !PlayerManager.is_in_shadow:
				set_state(States.EXIT_SHADOW_MELD)
				
			if !PlayerManager.is_inside:
				set_state(States.EXIT_SHADOW_MELD)
			
			if direction:
				velocity = velocity.lerp(direction * (SPEED * 1.5), delta)
			else:
				velocity = velocity.lerp(Vector2.ZERO, delta * 4)
		
		States.PREP_SHADOW_SHOT:
			velocity.x = 0
			trajectory_line.update_trajectory(global_position.direction_to(get_global_mouse_position()), 100.0, 9.8, delta)
			var mouse_dir = global_position.direction_to(get_global_mouse_position())
			if mouse_dir.x > 0:
				set_facing(Facing.RIGHT)
				
			if mouse_dir.x < 0:
				set_facing(Facing.LEFT)
				
			#match facing:
				#Facing.RIGHT:
					#grab_cast_right.enabled = true
					#grab_cast_left.enabled = false
					#pass
				#Facing.LEFT:
					#grab_cast_left.enabled = true
					#grab_cast_right.enabled = false
					#pass
		
		States.SHADOW_SHOT:
			if !PlayerManager.is_in_shadow:
				set_state(States.EXIT_SHADOW_MELD)
				
			for ray: RayCast2D in grab_rays:
				ray.force_raycast_update()
				
				if ray.is_colliding():
					var collider = ray.get_collider()
					if collider.is_in_group("Grabable") and !just_jumped:
						Audio.play("res://Audio/thwack-05.ogg", -20)
						velocity = Vector2.ZERO
						set_state(States.GRAB)
					#else:
						#set_state(States.IDLE)
			
			if is_on_floor() and !just_jumped:
				set_state(States.IDLE)
			
			if shadow_shot_ground_cast.is_colliding():
				Audio.play("res://Audio/thwack-05.ogg", -20)
				set_state(States.IDLE)
				
			var ground_ray = grab_cast_down
			grab_cast_down.force_raycast_update()
				
			if !ground_ray.is_colliding():
				just_jumped = false
			elif ground_ray.is_colliding():
				just_jumped = true
			
		States.GRAB:
			if !PlayerManager.is_in_shadow:
				set_state(States.IDLE)
			
			if grab_cast_left.is_colliding():
				animated_sprite.play("grab_wall")
				set_facing(Facing.RIGHT)
			
			if grab_cast_right.is_colliding():
				animated_sprite.play("grab_wall")
				set_facing(Facing.LEFT)
			
			if grab_cast_top.is_colliding() and !grab_cast_left.is_colliding() and !grab_cast_right.is_colliding():
				if direction:
					if direction.x > 0:
						set_facing(Facing.RIGHT)
					if direction.x < 0:
						set_facing(Facing.LEFT)
				animated_sprite.play("grab_ceiling")
			
			if direction:
				if grab_cast_left.is_colliding() or grab_cast_right.is_colliding():
					velocity.y = direction.y * SPEED
				if grab_cast_top.is_colliding():
					velocity.x = direction.x * SPEED
			
			if !direction:
				velocity = Vector2.ZERO
			
			if !grab_cast_top.is_colliding() and !grab_cast_right.is_colliding() and !grab_cast_left.is_colliding():
				set_state(States.IDLE)
			
		States.DEAD:
			velocity.x = 0

func ceiling_check() -> void:
	var top_ray = grab_cast_top
	
	top_ray.force_raycast_update()
	if top_ray.is_colliding():
		var collision_point = top_ray.get_collision_point()
		var diff = collision_point.y - global_position.y
		
		if diff < -25:
			diff = 0
			
		#print("Pos Difference: ", diff)
		global_position.y -= diff
		#print("Global Pos: ", global_position)

func ground_check() -> void:
	var ground_ray = grab_cast_down
	
	ground_ray.force_raycast_update()
	
	if ground_ray.is_colliding():
		var collision_point = ground_ray.get_collision_point()
		#print("Global Pos: ", global_position)
		#print("Collision Pos: ", collision_point)
		
		var diff = collision_point.y - global_position.y
		if diff > 45:
			diff = 0
			
		#print("Pos Difference: ", diff)
		global_position.y -= diff
		#print("Global Pos: ", global_position)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and PlayerManager.can_interact:
		PlayerManager.interact_target.interaction()
	
	if event.is_action_pressed("use_stairs") and state != States.SHADOW_MELD:
		#print("Trying to use stairs!")
		if PlayerManager.target_stairs:
			#print(PlayerManager.target_stairs)
			PlayerManager.target_stairs.interaction()
	
	if event.is_action_pressed("smoke_cigarette") and state == States.IDLE:
		animated_sprite.play("smoke")
		pass
	
	if event.is_action_pressed("activate_shadow_meld"):
		if state in [States.PREP_SHADOW_SHOT, States.MELEE, States.SHADOW_SHOT]:
			return
		match state:
			States.SHADOW_MELD:
				set_state(States.EXIT_SHADOW_MELD)
			_:
				set_state(States.SHADOW_MELD)
	
	if event.is_action_pressed("prep_jump") and state == States.GRAB:
		set_state(States.IDLE)
	
	if event.is_action_pressed("prep_jump") and is_on_floor():
		if state not in [States.IDLE, States.WALK]:
			return
		
		trajectory_line.visible = true
		set_state(States.PREP_SHADOW_SHOT)
	
	if event.is_action_released("prep_jump") and is_on_floor():
		if state not in [States.PREP_SHADOW_SHOT]:
			return
		
		trajectory_line.visible = false
		set_state(States.IDLE)
		
	if event.is_action_pressed("aim"):
		if state in [States.SHADOW_MELD, States.PREP_SHADOW_SHOT, States.MELEE, States.SHADOW_SHOT]:
			return
		if melee_cast.is_colliding():
			return
		
		PlayerManager.switch_aim(true)
		set_state(States.AIM)
	
	if event.is_action_released("aim"):
		if state in [States.SHADOW_MELD, States.PREP_SHADOW_SHOT, States.MELEE, States.SHADOW_SHOT]:
			return
			
		hand.rotation_degrees = idle_hand_rotation
		PlayerManager.switch_aim(false)
		#print(state)
		#print(last_state)
		set_state(last_state)
	
	if event.is_action_pressed("shoot") and state not in [States.PREP_SHADOW_SHOT, States.SHADOW_SHOT]:# and PlayerManager.is_aiming:
		if state in [States.SHADOW_MELD, States.PREP_SHADOW_SHOT, States.MELEE]:
			return
		
		if carried_weapon:
			if PlayerManager.is_aiming:
				match carried_weapon.weapon_type:
					"melee":
						carried_weapon.throw()
					"ranged":
						carried_weapon.shoot()
					_:
						print("no weapon type!")
				return
		if state == States.GRAB:
			return
		set_state(States.MELEE)
	
	if event.is_action_pressed("shoot") and (state == States.PREP_SHADOW_SHOT) and PlayerManager.is_in_shadow:
		velocity = global_position.direction_to(get_global_mouse_position()) * shadow_jump_strength
		trajectory_line.visible = false
		just_jumped = true
		set_state(States.SHADOW_SHOT)
	
	#if event.is_action_pressed("pause_game"):
		#if !PlayerManager.game_paused:
		#PlayerManager.game_paused = true
		#get_tree().paused = true
		#else:
			#PlayerManager.game_paused = false

func _on_animated_sprite_2d_animation_finished() -> void:
	match animated_sprite.animation:
		"melee":
			set_state(States.IDLE)
		"melee_knife":
			carried_weapon.visible = true
			set_state(States.IDLE)
		"damage":
			set_state(States.IDLE)
		"shadow_meld":
			animated_sprite.play("shadow_shape")
		"exit_shadow_meld":
			set_state(States.IDLE)
		"smoke":
			animated_sprite.play("smoke_flick")
		"smoke_flick":
			animated_sprite.play("idle")

func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite.animation in ["melee", "melee_knife"]:
	#match animated_sprite.animation:
		#"melee":
		if animated_sprite.frame == 2:
			melee_cast.force_raycast_update()
			if melee_cast.is_colliding():
				return
			var targets_to_hit = melee_hit_box.get_overlapping_bodies()
			
			if carried_weapon:
				carried_weapon.melee(targets_to_hit)
			else:
				if targets_to_hit:
					Audio.play("res://Audio/FX/qubodupPunch02.ogg", 0)
				for target in targets_to_hit:
					PlayerManager.deal_damage(target, 1)
					target.set_state(target.States.DAMAGE)

func handle_interactions() -> void:
	if PlayerManager.possible_interactions.is_empty():
		PlayerManager.can_interact = false
		return
	
	var closest = null
	var chosen_target = null
	
	for node in PlayerManager.possible_interactions:
		#var distance = node.global_position.distance_to(PlayerManager.player.position)
		var distance = PlayerManager.player.global_position.x - node.global_position.x
		if not closest:
			closest = distance
			chosen_target = node
		else:
			if distance < closest:
				closest = distance
				chosen_target = node
	
	#print(chosen_target)
	PlayerManager.interact_target = chosen_target
	PlayerManager.can_interact = true

func _on_interaction_area_area_entered(area: Area2D) -> void:
	PlayerManager.possible_interactions.append(area.get_parent())
	#print(PlayerManager.possible_interactions)

func _on_interaction_area_area_exited(area: Area2D) -> void:
	PlayerManager.possible_interactions = PlayerManager.possible_interactions.filter(
		func(interaction): return interaction != area.get_parent()
	)
	#print(PlayerManager.possible_interactions)
