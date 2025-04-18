extends CharacterBody2D
class_name Player

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

@export_range(500.0, 1500.0) var throw_power: float = 800.0
@export_range(500, 2500.0) var shadow_jump_strength: float = 100.0

#@export var hand_left_position: Vector2
#@export var hand_right_position: Vector2

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

@onready var collision_shape: CollisionShape2D = $CollisionShape
@onready var shadow_collision = $ShadowCollisionShape

@onready var grab_rays = [grab_cast_top, grab_cast_right, grab_cast_left]
@onready var melee_hit_box: Area2D = $MeleeHitBox

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var just_jumped := false

var carried_weapon: Weapon = null
var secondary_weapon: Weapon = null

var health = 2

enum States {
	IDLE,
	AIM,
	MELEE,
	WALK,
	DUCT,
	SHADOW_MELD,
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

func _ready():
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
		if state in [States.IDLE, States.WALK, States.SHADOW_SHOT, States.DEAD]:
			velocity += get_gravity() * (delta * 2)
		if state in [States.DUCT]:
			velocity = velocity.lerp(Vector2.ZERO, delta)
	
	handle_facing()
	handle_states(delta)
	
	move_and_slide()

func handle_states(delta) -> void:
	if PlayerManager.game_complete:
		set_state(States.IDLE)
		velocity = Vector2.ZERO
		return
	
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	match state:
		States.IDLE:
			if direction.x:
				set_state(States.WALK)
			velocity.x = 0
		
		States.DAMAGE:
			velocity = Vector2.ZERO
		
		States.WALK:
			if direction.x:
				velocity.x = direction.x * SPEED
			else:
				set_state(States.IDLE)
			
			if direction.x < 0:
				set_facing(Facing.LEFT)
			elif direction.x > 0:
				set_facing(Facing.RIGHT)
		
		States.MELEE:
			velocity = Vector2.ZERO
		
		States.AIM:
			hand.look_at(get_global_mouse_position())
			velocity = velocity.lerp(Vector2.ZERO, delta * 4)
			
		States.DUCT:
			pass
			
		States.SHADOW_MELD:
			if !PlayerManager.is_in_shadow:
				set_state(States.IDLE)
				
			if !PlayerManager.is_inside:
				set_state(States.IDLE)
			
			if direction:
				velocity = velocity.lerp(direction * (SPEED * 1.5), delta)
			else:
				velocity = velocity.lerp(Vector2.ZERO, delta * 4)
			
		States.PREP_SHADOW_SHOT:
			velocity = Vector2.ZERO
			trajectory_line.update_trajectory(global_position.direction_to(get_global_mouse_position()), 100.0, 9.8, delta)
			
		States.SHADOW_SHOT:
			if shadow_shot_ground_cast.is_colliding():
				set_state(States.IDLE)
				
			if !PlayerManager.is_in_shadow:
				set_state(States.IDLE)
				
			var ground_ray = grab_cast_down
			grab_cast_down.force_raycast_update()
			
			if is_on_floor() and !just_jumped:
				set_state(States.IDLE)
			
			for ray: RayCast2D in grab_rays:
				ray.force_raycast_update()
				var collider = ray.get_collider()
				
				if ray.is_colliding():
					if collider.is_in_group("Grabable") and !just_jumped:
						velocity = Vector2.ZERO
						#ground_check()
						set_state(States.GRAB)
					else:
						set_state(States.IDLE)
						
			if !ground_ray.is_colliding():
				just_jumped = false
			elif ground_ray.is_colliding():
				just_jumped = true
			
		States.GRAB:
			if !PlayerManager.is_in_shadow:
				set_state(States.IDLE)
			
			if direction:
				if grab_cast_left.is_colliding() or grab_cast_right.is_colliding():
					velocity.y = lerp(velocity.y, direction.y * SPEED, delta * 2)
				if grab_cast_top.is_colliding():
					velocity.x = lerpf(velocity.x, direction.x * SPEED, delta * 2)
			
			if !direction:
				velocity = velocity.lerp(Vector2.ZERO, delta * 6)
			
			if !grab_cast_top.is_colliding() and !grab_cast_right.is_colliding() and !grab_cast_left.is_colliding():
				set_state(States.IDLE)
			
		States.DEAD:
			rotation_degrees = lerp(rotation_degrees, 90.0, delta * 6)
			velocity = velocity.lerp(Vector2.ZERO, delta * 4)

func set_state(new_state: States):
	if state not in [States.SHADOW_MELD]:
		set_collision_mask_value(5, 1)
	
	if state in [States.SHADOW_SHOT, States.SHADOW_MELD]:
		grab_cast_down.enabled = true
		ground_check()
		grab_cast_down.enabled = false
	
	if new_state in [States.IDLE, States.WALK]:
		hand_sprite.visible = false
	
	match new_state:
		States.DEAD:
			PlayerManager.is_player_dead = true
		
		States.DAMAGE:
			var blood_spatter = preload("res://Scenes/black_blood_spatter.tscn").instantiate()
			blood_spatter.global_position = global_position
			get_tree().get_first_node_in_group("BackWall").add_child(blood_spatter)
			animated_sprite.play("damage")
			# State switch on animation_finished
			#set_state(States.IDLE)
		
		States.IDLE:
			animated_sprite.play("idle")
			collision_shape.disabled = false
			#shadow_collision.disabled = true
			
		States.WALK:
			match facing:
				Facing.RIGHT:
					animated_sprite.flip_h = true
				Facing.LEFT:
					animated_sprite.flip_h = false
					
			animated_sprite.play("walk")
		
		States.SHADOW_MELD:
			set_collision_mask_value(5, 0)
			collision_shape.disabled = true
			#shadow_collision.disabled = false
			animated_sprite.play("shadow_shape")
		
		States.SHADOW_SHOT:
			Audio.play("res://Audio/FX/cloth3.ogg", +5)
			if !PlayerManager.is_in_shadow:
				set_state(States.IDLE)
				
			collision_shape.disabled = true
			#shadow_collision.disabled = false
			animated_sprite.play("shadow_shape")
				
		States.MELEE:
			animated_sprite.play("melee")
		
		States.GRAB:
			collision_shape.disabled = false
			#shadow_collision.disabled = true
			animated_sprite.play("idle")
		
		States.AIM:
			hand_sprite.visible = true
			animated_sprite.play("aim")
		#_:
			#grab_cast_top.target_position = grab_cast_top.target_position + Vector2(0, +21)
			#collision_shape.disabled = false
			#animated_sprite.play("idle")
			#set_collision_mask_value(5, 1)
			#polygon.polygon = player_base_shape
		
	if new_state != state:
		last_state = state
		state = new_state

func ground_check() -> void:
	var ground_ray = grab_cast_down
	
	ground_ray.force_raycast_update()
	
	if ground_ray.is_colliding():
		var collision_point = ground_ray.get_collision_point()
		
		print(global_position)
		print(collision_point)
		# TODO: Fix this!
		var diff = collision_point.y - global_position.y
		
		print(diff)
		global_position.y -= diff
		print(global_position)
	

func set_facing(new_facing) -> void:
	if new_facing != facing:
		facing = new_facing

func handle_facing() -> void:
	match facing:
		Facing.LEFT:
			melee_hit_box.position = $HitBoxPosLeft.position
			hand.position = left_shoulder_pos.position
			animated_sprite.flip_h = true
			hand.rotation_degrees = 90
			
		Facing.RIGHT:
			melee_hit_box.position = $HitBoxPosRight.position
			hand.position = right_shoulder_pos.position
			animated_sprite.flip_h = false
			hand.rotation_degrees = 40
			

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and PlayerManager.can_interact:
		PlayerManager.interact_target.interaction()
	
	if event.is_action_pressed("activate_shadow_meld") and PlayerManager.is_inside:
		match state:
			States.SHADOW_MELD:
				set_state(States.IDLE)
			_:
				set_state(States.SHADOW_MELD)
	
	if event.is_action_pressed("ui_accept") and state == States.GRAB:
		set_state(States.IDLE)
		
	#if event.is_action_pressed("interact") and VentManager.current_waypoint.is_exit:
		#set_state(States.IDLE)
		
	if event.is_action_pressed("ui_accept") and is_on_floor():
		if state not in [States.IDLE, States.WALK]:
			return
		
		trajectory_line.visible = true
		set_state(States.PREP_SHADOW_SHOT)
	
	if event.is_action_released("ui_accept") and is_on_floor():
		if state not in [States.PREP_SHADOW_SHOT]:
			return
		
		trajectory_line.visible = false
		set_state(States.IDLE)
		
	if event.is_action_pressed("aim"):
		if state in [States.SHADOW_MELD, States.PREP_SHADOW_SHOT, States.MELEE]:
			return
			
		PlayerManager.switch_aim(true)
		set_state(States.AIM)
	
	if event.is_action_released("aim"):
		if state in [States.SHADOW_MELD, States.PREP_SHADOW_SHOT, States.MELEE]:
			return
			
		#hand.rotation_degrees = 40
		PlayerManager.switch_aim(false)
		
		set_state(last_state)
	
	if event.is_action_pressed("shoot") and state != States.PREP_SHADOW_SHOT:# and PlayerManager.is_aiming:
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
		set_state(States.MELEE)
	
	if event.is_action_pressed("shoot") and (state == States.PREP_SHADOW_SHOT) and PlayerManager.is_in_shadow:
		velocity = global_position.direction_to(get_global_mouse_position()) * shadow_jump_strength
		trajectory_line.visible = false
		just_jumped = true
		set_state(States.SHADOW_SHOT)

func _on_animated_sprite_2d_animation_finished() -> void:
	match animated_sprite.animation:
		"melee":
			set_state(States.IDLE)
		"damage":
			set_state(States.IDLE)

func _on_animated_sprite_2d_frame_changed() -> void:
	match animated_sprite.animation:
		"melee":
			if animated_sprite.frame == 2:
				var targets_to_hit = melee_hit_box.get_overlapping_bodies()
				
				if carried_weapon:
					carried_weapon.melee(targets_to_hit)
				else:
					for target in targets_to_hit:
						PlayerManager.deal_damage(target, 1)
						target.set_state(target.States.DAMAGE)
				
