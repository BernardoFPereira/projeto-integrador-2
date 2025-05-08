extends CharacterBody2D
class_name Enemy

@export_enum("MELEE", "RANGED") var enemy_type := "MELEE"

@export var facing: Facing
@export var start_state := States.IDLE
@export_range(200.0, 800.0, 1.0) var speed := 150.0
@export var attack_cooldown := 1.0

@export_category("Roaming")
@export_range(80.0, 300.0, 1.0) var roam_speed := 100.0
@export var min_wait := 2.0
@export var max_wait := 6.0

@onready var muzzle: Marker2D = $Muzzle
@onready var sound_range: Area2D = $SoundRange
@onready var enemy_hit_box: Area2D = $Muzzle/EnemyHitBox

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast: RayCast2D = $RayCast
@onready var sight_area: Area2D = $SightArea
@onready var dark_sight_area: Area2D = $DarkSightArea

@onready var suspicion_timer: Timer = $SuspicionTimer
@onready var roaming_timer: Timer = $RoamingTimer
@onready var search_location_timer: Timer = $SearchLocationTimer
@onready var search_timer: Timer = $SearchTimer
@onready var interaction_timer: Timer = $InteractionTimer
@onready var aim_timer: Timer = $AimTimer

#@onready var icon: Sprite2D = $AlertIcon/Icon
@onready var state_sprite: AnimatedSprite2D = $AlertIcon/StateSprite

@onready var body_collision_shape: CollisionShape2D = $BodyCollisionShape
@onready var head_collision_shape: CollisionShape2D = $HeadCollisionShape
@onready var dead_collision_shape: CollisionShape2D = $DeadCollisionShape

@onready var head_facing_right_pos: Marker2D = $HeadFacingRightPos
@onready var head_facing_left_pos: Marker2D = $HeadFacingLeftPos

@onready var body_facing_right_pos: Marker2D = $BodyFacingRightPos
@onready var body_facing_left_pos: Marker2D = $BodyFacingLeftPos

@onready var muzzle_right_pos: Marker2D = $MuzzleRightPos
@onready var muzzle_left_pos: Marker2D = $MuzzleLeftPos

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

signal decrement_counter

enum States {
	IDLE,
	SUSPICIOUS,
	SEARCH,
	GOING_UP,
	GOING_DOWN,
	CHASE,
	ROAMING,
	ATTACK,
	COOLDOWN,
	DAMAGE,
	AIM,
	DEAD
}

enum Facing { LEFT, RIGHT }

var state: States
var player_last_pos: Vector2

var chase_target: Node2D
var is_player_on_sight := false

var target_position := Vector2.ZERO
var ammo := 8
var cooldown_counter := 0.0
var health := 2
var roam_timer

var can_interact := false
#var just_interacted := false
var interaction_target: Node2D

var ready_to_shoot := false

func _ready() -> void:
	set_state(start_state)
	roaming_timer.wait_time = randf_range(2.0, 4.5)
	chase_target = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	if health <= 0:
		set_state(States.DEAD)
		
	if velocity.x > 0:
		set_facing(Facing.RIGHT)
	if velocity.x < 0:
		set_facing(Facing.LEFT)
	
	if PlayerManager.is_player_dead:
		if state not in [States.IDLE, States.ROAMING, States.DEAD]:
			set_state(States.ROAMING)
	
	if PlayerManager.is_in_shadow:
		dark_sight_area.monitoring = true
		sight_area.monitoring = false
	elif !PlayerManager.is_in_shadow:
		dark_sight_area.monitoring = false
		sight_area.monitoring = true
	
	handle_states(delta)
	handle_facing()
	
func set_investigation_target() -> void:
	pass

func set_facing(new_facing) -> void:
	if new_facing != facing:
		facing = new_facing

func handle_facing() -> void:
	match facing:
		Facing.LEFT:
			sight_area.scale.x = -1.0
			dark_sight_area.scale.x = -1.0
			animated_sprite.flip_h = true
			
			head_collision_shape.position = head_facing_left_pos.position
			body_collision_shape.position = body_facing_left_pos.position
			muzzle.position = muzzle_left_pos.position
			
		Facing.RIGHT:
			sight_area.scale.x = 1.0
			dark_sight_area.scale.x = 1.0
			animated_sprite.flip_h = false
			
			head_collision_shape.position = head_facing_right_pos.position
			body_collision_shape.position = body_facing_right_pos.position
			muzzle.position = muzzle_right_pos.position


func set_state(new_state: States) -> void:
	var suspicious_icon = preload("res://Sprites/alert_icons2.png")
	var alert_icon = preload("res://Sprites/alert_icons1.png")
	
	if state == States.DEAD:
		return
	
	#if new_state != state:
	match new_state:
		States.DEAD:
			emit_signal("decrement_counter")
			velocity.x = 0
			set_collision_mask_value(5, 0)
			body_collision_shape.disabled = true
			head_collision_shape.disabled = true
			dead_collision_shape.disabled = false
			
			sight_area.monitoring = false
			dark_sight_area.monitoring = false
			interaction_target = null
			
			state_sprite.visible = false
			state_sprite.stop()
			#icon.texture = null
			
			roaming_timer.stop()
			suspicion_timer.stop()
			search_location_timer.stop()
			search_timer.stop()
			
			animated_sprite.play("dead")
		States.DAMAGE:
			if health >= 0:
				animated_sprite.play("damage")
		States.IDLE:
			state_sprite.visible = false
			state_sprite.stop()
			state_sprite.self_modulate = Color.WHITE
			
			animated_sprite.play("idle")
		States.ROAMING:
			state_sprite.stop()
			state_sprite.visible = false
			
			roaming_timer.start()
			suspicion_timer.stop()
			search_location_timer.stop()
			search_timer.stop()
			
			animated_sprite.play("walk")
		States.SUSPICIOUS:
			state_sprite.self_modulate = Color.WHITE
			state_sprite.visible = true
			state_sprite.play("search")
			#icon.texture = suspicious_icon
			
			suspicion_timer.start()
			roaming_timer.stop()
			search_location_timer.stop()
			search_timer.stop()
			
			#animated_sprite.play("idle")
		States.CHASE:
			state_sprite.visible = true
			state_sprite.self_modulate = Color.RED
			state_sprite.play("detected")
			#icon.texture = alert_icon
			
			roaming_timer.stop()
			suspicion_timer.stop()
			search_location_timer.stop()
			search_timer.stop()
			animated_sprite.play("walk")
		States.SEARCH:
			if state == States.AIM:
				aim_timer.stop()
				
			#target_position = look_for_stairs()
			match y_diff():
				"below":
					#print("Player still below me")
					print("Player on the below floor. Entering GOING_DOWN")
					set_state(States.GOING_DOWN)
					return
				"above":
					#print("Player still above me")
					print("Player on the above floor. Entering GOING_UP")
					set_state(States.GOING_UP)
					return
				_:
					print("Player on the same floor. Entering SEARCH")
					pass
			
			state_sprite.visible = true
			state_sprite.self_modulate = Color.ORANGE
			state_sprite.play("search")
			#icon.texture = suspicious_icon
			
			search_location_timer.start()
			search_timer.start()
			roaming_timer.stop()
			suspicion_timer.stop()
			animated_sprite.play("walk")
		States.AIM:
			velocity.x = 0
			animated_sprite.play("aim")
			aim_timer.start()
		States.ATTACK:
			velocity.x = 0
			animated_sprite.play("attack")
		States.GOING_UP:
			
			state_sprite.visible = true
			state_sprite.self_modulate = Color.ORANGE
			state_sprite.play("search")
			#icon.texture = suspicious_icon
			
			target_position = look_for_stairs()
			
			if target_position == self.global_position:
				set_state(States.ROAMING)
				
			search_location_timer.stop()
			search_timer.stop()
			roaming_timer.stop()
			suspicion_timer.stop()
			
			animated_sprite.play("walk")
		States.GOING_DOWN:
			state_sprite.visible = true
			state_sprite.self_modulate = Color.ORANGE
			state_sprite.play("search")
			
			target_position = look_for_stairs()
			
			if target_position == self.global_position:
				set_state(States.ROAMING)
			
			print(target_position)
			print(global_position)
			search_location_timer.stop()
			search_timer.stop()
			roaming_timer.stop()
			suspicion_timer.stop()
			
			animated_sprite.play("walk")
		#_:
			#print(state)
			#state_sprite.visible = false
			#state_sprite.stop()
			#
			#roaming_timer.stop()
			#suspicion_timer.stop()
			#search_location_timer.stop()
			#search_timer.stop()
		
	state = new_state

func handle_states(delta) -> void:
	if !is_on_floor():
		velocity += get_gravity() * (delta * 2)
		
	match state:
		States.DEAD:
			#rotation_degrees = lerp(rotation_degrees, 90.0, delta * 6)
			velocity.x = 0
		States.IDLE:
			if is_player_on_sight and !detected_obstacle():
				#if PlayerManager.is_in_shadow:
					#ray_cast.target_position / 2
				set_state(States.SUSPICIOUS)
		States.SUSPICIOUS:
			# wait to see if player stays in sight
			pass
		States.CHASE:
			target_position = chase_target.global_position
			
			if detected_obstacle() or !is_player_on_sight:
				set_state(States.SEARCH)
			
			var distance_to_player = global_position.distance_to(target_position)
			var direction_to_player = global_position.direction_to(chase_target.global_position).normalized()
			
			match enemy_type:
				"MELEE":
					if distance_to_player < 50:
						set_state(States.AIM)
				"RANGED":
					if is_player_on_sight:
						set_state(States.AIM)
			if !(global_position.distance_to(target_position) < 20):
				velocity.x = direction_to_player.x * speed
		States.AIM:
			velocity.x = 0
			#if player_last_pos.x > 0:
				#set_facing(Facing.RIGHT)
			#if player_last_pos.x < 0:
				#set_facing(Facing.LEFT)
			if !is_player_on_sight:
				set_state(States.SEARCH)
			# TODO: Fix click_fx spawn and despawn
			#match enemy_type:
				#"RANGED":
					#var click_fx = preload("res://Scenes/FX/click_fx.tscn").instantiate()
					#
					#if aim_timer.time_left <= 0.5:
					#
						#if ready_to_shoot:
							#click_fx.position = muzzle.position
							#add_child(click_fx)
							#print("ready!")
							#ready_to_shoot = false
							#
						#else:
							#ready_to_shoot = true
				#_:
					#pass
		States.ATTACK:
			match enemy_type:
				"MELEE":
					
					var slash_fx = preload("res://Scenes/FX/enemy_slash.tscn").instantiate()
					var offset = Vector2(25, 0)
					
					match facing:
						Facing.RIGHT:
							slash_fx.flip_h = true
							slash_fx.global_position = global_position + offset
						
						Facing.LEFT:
							slash_fx.global_position = global_position - offset
					get_tree().root.add_child(slash_fx)
					
					var possible_targets = enemy_hit_box.get_overlapping_bodies()
					if possible_targets != null and !possible_targets.is_empty():
						PlayerManager.deal_damage(PlayerManager.player, 1)
						PlayerManager.player.set_state(PlayerManager.player.States.DAMAGE)
					
					set_state(States.COOLDOWN)
					
				"RANGED":
					#var click_fx = find_child("ClickFx", true)
					#if click_fx:
						#click_fx.queue_free()
					
					shoot()
					
					set_state(States.COOLDOWN)
					pass
		States.COOLDOWN:
			cooldown_counter += delta
			if cooldown_counter >= attack_cooldown:
				if is_player_on_sight:
					set_state(States.CHASE)
				else:
					set_state(States.ROAMING)
				cooldown_counter = 0.0
		States.GOING_UP:
			if !(global_position.distance_to(target_position) < 20):
				velocity.x = global_position.direction_to(target_position).x * (roam_speed * 2)
			
			if can_interact:# and !just_interacted:
				#interaction_timer.start()
				#just_interacted = true
				interaction_target.interaction("ENEMY")
				set_state(States.SEARCH)
		States.GOING_DOWN:
			if !(global_position.distance_to(target_position) < 20):
				velocity.x = global_position.direction_to(target_position).x * (roam_speed * 2)
			#velocity.x = lerpf(velocity.x, global_position.direction_to(target_position).x * (roam_speed * 2), delta * 2)
			
			if can_interact:# and !just_interacted:
				#interaction_timer.start()
				#just_interacted = true
				interaction_target.interaction("ENEMY")
				set_state(States.SEARCH)
				can_interact = false
		States.SEARCH:
			#var search_offset = Vector2(randf_range(-350, 350), 0)
			if !(global_position.distance_to(target_position) < 10):
				velocity.x = global_position.direction_to(player_last_pos).x * roam_speed
			#velocity.x = lerpf(velocity.x, global_position.direction_to(player_last_pos + search_offset).x * roam_speed, delta * 2)
			
			if velocity.x == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("walk")
			
			if is_player_on_sight and !detected_obstacle():
				set_state(States.CHASE)
		States.ROAMING:
			if !(global_position.distance_to(target_position) < 100):
				velocity.x = global_position.direction_to(target_position).x * roam_speed
			#velocity.x = lerpf(velocity.x, global_position.direction_to(target_position).x * roam_speed, delta * 2)
			#if is_on_wall():
				#roaming_timer.stop()
				#roaming_timer.wait_time = 0.5
				#roaming_timer.start()
			
			if velocity.x == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("walk")
			
			if is_player_on_sight and !detected_obstacle():
				if PlayerManager.is_player_dead:
					set_state(States.ROAMING)
				else:
					set_state(States.SUSPICIOUS)
			
	move_and_slide()

func shoot() -> void:
	broadcast_noise()
	#if current_ammo > 0:
	var muzzle_flash_fx = preload("res://Scenes/FX/muzzle_flash_fx.tscn").instantiate()
	var muzzle_flash = preload("res://Scenes/FX/muzzle_flash.tscn").instantiate()
	var projectile = preload("res://Scenes/Weapons/bullet.tscn").instantiate()

	# Point projectile towards target
	projectile.look_at(PlayerManager.player.global_position)
	
	# Spawn projectile
	muzzle_flash_fx.global_transform = muzzle.global_transform
	muzzle_flash_fx.rotate(deg_to_rad(90))
	muzzle_flash.global_transform = muzzle.global_transform
	
	projectile.global_transform = muzzle.global_transform
	projectile.targ_dir = global_position.direction_to(PlayerManager.player.global_position)
	projectile.set_collision_mask_value(2, 1)
	
	get_tree().root.add_child(muzzle_flash_fx)
	get_tree().root.add_child(muzzle_flash)
	get_tree().root.add_child(projectile)
	ammo -= 1
	
	audio_stream_player.play()
	
func broadcast_noise() -> void:
	var bodies_in_range = sound_range.get_overlapping_bodies()
	if bodies_in_range:
		for body: Enemy in bodies_in_range:
			if body.state != body.States.DEAD:
				body.player_last_pos = PlayerManager.player.global_position
				body.set_state(body.States.SEARCH)
				
func detected_obstacle() -> bool:
	var target_distance = ray_cast.global_position.distance_to(chase_target.global_position)
	ray_cast.look_at(chase_target.global_position)
	ray_cast.target_position = Vector2(target_distance,0)
	#ray_cast.force_raycast_update()
	
	var collision = ray_cast.get_collider()
	
	if collision:
		if collision.is_class("CharacterBody2D"):
			return false
	return true

func look_for_stairs() -> Vector2:
	var all_stairs = get_tree().get_nodes_in_group("Stair")
	var target_stairs: Array[Node]
	print("looking for stairs")
	match y_diff():
		"below":
		#	look for nearest stairs that lead down
			var down_stairs = all_stairs.filter(
				func(stairs): return stairs.direction == stairs.Direction.DOWN
				)
			
			target_stairs = down_stairs.filter(
					func(stairs): return ((global_position.y - stairs.global_position.y) < 130) and ((global_position.y - stairs.global_position.y) > -200) 
				)
		"above":
			var up_stairs = all_stairs.filter(
				func(stairs): return stairs.direction == stairs.Direction.UP
				)
			
			target_stairs = up_stairs.filter(
					func(stairs): return ((global_position.y - stairs.global_position.y) < 130) and ((global_position.y - stairs.global_position.y) > -200)
				)
	if target_stairs.is_empty():
		return PlayerManager.player.global_position
	
	return target_stairs[0].global_position


func y_diff() -> String:
	var y_diff = player_last_pos.y - global_position.y
	
	if y_diff > 130:
		#print(y_diff)
		#print("%s: player is BELOW me!" % self.name)
		return "below"
	elif y_diff < -200:
		#print(y_diff)
		#print("%s: player is ABOVE me!" % self.name)
		return "above"
	#elif y_diff < 130 and y_diff > -200:
		#print("%s: player is on the SAME FLOOR as me!" % self.name)
	#print(y_diff)
	return "same"
		
func _on_sight_area_body_entered(body: Node2D) -> void:
	#chase_target = body
	is_player_on_sight = true
	
func _on_sight_area_body_exited(body: Node2D) -> void:
	is_player_on_sight = false
	player_last_pos = body.global_position
	ray_cast.target_position = Vector2.ZERO
	
	if detected_obstacle():
		return
	
	#set_state(States.SEARCH)

func _on_interact_area_area_entered(area: Area2D) -> void:
	#print("Enemy on stairs!")
	interaction_target = area.get_parent()
	match state:
		States.GOING_UP:
			if interaction_target.direction == interaction_target.Direction.UP:
				can_interact = true
			pass
		
		States.GOING_DOWN:
			if interaction_target.direction == interaction_target.Direction.DOWN:
				can_interact = true
			pass
	#print(interaction_target.name)
	#can_interact = true

func _on_interact_area_area_exited(area: Area2D) -> void:
	interaction_target = null
	can_interact = false

func _on_suspicion_timer_timeout() -> void:
	set_state(States.CHASE)

func _on_roaming_timer_timeout() -> void:
	var roaming_offset = Vector2(randf_range(-350, 350), 0)
	target_position = global_position + roaming_offset
	
	if global_position.distance_to(target_position) < 100 or is_on_wall():
		target_position = global_position
		velocity = Vector2.ZERO
	
	roaming_timer.wait_time = randf_range(min_wait, max_wait)

func _on_search_timer_timeout() -> void:
	set_state(States.ROAMING)

func _on_search_location_timer_timeout() -> void:
	print("changing search location")
	var search_offset = Vector2(randf_range(-400, 400), 0)
	target_position = player_last_pos + search_offset
	print("target_position: %s" % target_position)
	if global_position.distance_to(target_position) < 50 or is_on_wall():
		print("target_position zeroed on my position: %s" % target_position)
		target_position = global_position
		velocity = Vector2.ZERO
	
	search_location_timer.wait_time = randf_range(min_wait, max_wait)
	search_location_timer.start()

#func _on_interaction_timer_timeout() -> void:
	#print("can interact again!")
	#just_interacted = false
	#can_interact = true

func _on_animated_sprite_2d_animation_finished() -> void:
	match animated_sprite.animation:
		"damage":
			set_state(States.SEARCH)
		_:
			pass

func _on_aim_timer_timeout() -> void:
	set_state(States.ATTACK)
