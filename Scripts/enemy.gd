extends CharacterBody2D
class_name Enemy

@export var facing: Facing
@export var start_state := States.IDLE
@export_range(200.0, 800.0, 1.0) var speed := 600.0
@export var attack_cooldown := 1.0

@export_category("Roaming")
@export_range(80.0, 300.0, 1.0) var roam_speed := 100.0
@export var min_wait := 2.0
@export var max_wait := 4.5

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast: RayCast2D = $RayCast
@onready var sight_area: Area2D = $SightArea

@onready var suspicion_timer: Timer = $SuspicionTimer
@onready var roaming_timer: Timer = $RoamingTimer
@onready var search_location_timer: Timer = $SearchLocationTimer
@onready var search_timer: Timer = $SearchTimer
@onready var interaction_timer: Timer = $InteractionTimer

@onready var icon: Sprite2D = $AlertIcon/Icon

@onready var body_collision_shape: CollisionShape2D = $BodyCollisionShape
@onready var head_collision_shape: CollisionShape2D = $HeadCollisionShape

@onready var head_facing_right_pos: Marker2D = $HeadFacingRightPos
@onready var head_facing_left_pos: Marker2D = $HeadFacingLeftPos

@onready var body_facing_right_pos: Marker2D = $BodyFacingRightPos
@onready var body_facing_left_pos: Marker2D = $BodyFacingLeftPos

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
	DEAD
}

enum Facing { LEFT, RIGHT }

var state: States
var player_last_pos: Vector2

var chase_target: Node2D
var is_player_on_sight := false

var target_position := Vector2.ZERO
var cooldown_counter := 0.0
var health_points := 2

var can_interact := false
var just_interacted := false
var interaction_target: Node2D

func _ready() -> void:
	set_state(start_state)
	roaming_timer.wait_time = randf_range(2.0, 4.5)
	chase_target = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	if health_points <= 0:
		set_state(States.DEAD)
		
	if velocity.x > 0:
		set_facing(Facing.RIGHT)
	if velocity.x < 0:
		set_facing(Facing.LEFT)
	
	if PlayerManager.player.health <= 0:
		if state not in [States.IDLE, States.ROAMING, States.DEAD]:
			set_state(States.ROAMING)
	
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
			animated_sprite.flip_h = true
			
			head_collision_shape.position = head_facing_left_pos.position
			body_collision_shape.position = body_facing_left_pos.position
			
		Facing.RIGHT:
			sight_area.scale.x = 1.0
			animated_sprite.flip_h = false
			
			head_collision_shape.position = head_facing_right_pos.position
			body_collision_shape.position = body_facing_right_pos.position

func set_state(new_state: States) -> void:
	var suspicious_icon = preload("res://Sprites/alert_icons2.png")
	var alert_icon = preload("res://Sprites/alert_icons1.png")
	
	if new_state != state:
		match new_state:
			States.DEAD:
				sight_area.monitoring = false
				interaction_target = null
				icon.texture = null
				
				roaming_timer.stop()
				suspicion_timer.stop()
				search_location_timer.stop()
				search_timer.stop()
			
			States.ROAMING:
				icon.texture = null
				
				roaming_timer.start()
				suspicion_timer.stop()
				search_location_timer.stop()
				search_timer.stop()
			
			States.SUSPICIOUS:
				icon.texture = suspicious_icon
				
				suspicion_timer.start()
				roaming_timer.stop()
				search_location_timer.stop()
				search_timer.stop()
			
			States.CHASE:
				icon.texture = alert_icon
				
				roaming_timer.stop()
				suspicion_timer.stop()
				search_location_timer.stop()
				search_timer.stop()
			
			States.SEARCH:
				var y_diff = player_last_pos.y - global_position.y
				if y_diff > 200:
					#print(y_diff)
					print("%s: player shot BELOW me!" % self.name)
					set_state(States.GOING_DOWN)
				
				elif y_diff < -200:
					print(y_diff)
					print("%s: player shot ABOVE me!" % self.name)
					set_state(States.GOING_UP)
				
				elif y_diff < 130 and y_diff > -200:
					print(y_diff)
					print("%s: player shot on the SAME FLOOR as me!" % self.name)
					
				#if player_last_pos.y - global_position.y < 0:
					#print("%s is Going Up!" % self.name)
					#set_state(States.GOING_UP)
				#
				#if player_last_pos.y - global_position.y > 0:
					#print("%s is Going Down!" % self.name)
					#set_state(States.GOING_DOWN)
				
				icon.texture = suspicious_icon
				
				search_location_timer.start()
				search_timer.start()
				roaming_timer.stop()
				suspicion_timer.stop()
			_:
				icon.texture = null
				
				roaming_timer.stop()
				suspicion_timer.stop()
				search_location_timer.stop()
				search_timer.stop()
			
		state = new_state

func handle_states(delta) -> void:
	if !is_on_floor():
		velocity += get_gravity() * (delta * 2)
		
	match state:
		States.DEAD:
			rotation_degrees = lerp(rotation_degrees, 90.0, delta * 6)
			velocity.x = lerpf(velocity.x, 0.0, delta * 4)
			
		States.IDLE:
			if is_player_on_sight and !detected_obstacle():
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
			if distance_to_player < 50:
				set_state(States.ATTACK)
			
			velocity.x = lerpf(velocity.x, direction_to_player.x * speed, delta * 4)
			
		States.ATTACK:
			var slash_fx = preload("res://Scenes/enemy_slash.tscn").instantiate()
			var offset = Vector2(25, 0)
			
			match facing:
				Facing.RIGHT:
					slash_fx.flip_h = true
					slash_fx.global_position = global_position + offset
				
				Facing.LEFT:
					slash_fx.global_position = global_position - offset
				
			get_tree().root.add_child(slash_fx)
			PlayerManager.deal_damage(1)
			set_state(States.COOLDOWN)
			
		States.COOLDOWN:
			cooldown_counter += delta
			if cooldown_counter >= attack_cooldown:
				if is_player_on_sight:
					set_state(States.CHASE)
				else:
					set_state(States.ROAMING)
				cooldown_counter = 0.0
			pass
			
		States.GOING_UP:
			print("LOOK FOR STARIS UP")
			pass
		
		States.GOING_DOWN:
			print("LOOK FOR STARIS DOWN")
			pass
		
		States.SEARCH:
			var search_offset = Vector2(randf_range(-250, 250), 0)
			velocity.x = lerpf(velocity.x, global_position.direction_to(player_last_pos + search_offset).x * roam_speed, delta * 2)
			
			if can_interact and !just_interacted:
				interaction_timer.start()
				just_interacted = true
				interaction_target.interaction("ENEMY")
			
			if is_player_on_sight and !detected_obstacle():
				set_state(States.CHASE)
		
		States.ROAMING:
			velocity.x = lerpf(velocity.x, global_position.direction_to(target_position).x * roam_speed, delta * 2)
			
			if is_player_on_sight and !detected_obstacle():
				if PlayerManager.player.health <= 0:
					set_state(States.ROAMING)
				else:
					set_state(States.SUSPICIOUS)
			
	move_and_slide()

func detected_obstacle() -> bool:
	var target_distance = ray_cast.global_position.distance_to(chase_target.global_position)
	ray_cast.look_at(chase_target.global_position)
	ray_cast.target_position = Vector2(target_distance,0)
	ray_cast.force_raycast_update()
	
	var collision = ray_cast.get_collider()
	
	if collision:
		if collision.is_class("CharacterBody2D"):
			return false
	return true

func look_for_stairs() -> void:
	# If searching and player_pos.y is below me
	if player_last_pos.y > global_position.y:
	#	look for nearest stairs that lead down
	#	move to nearest stairs
	#	set_state(States.SEARCH)
		pass
	# elif searching and player_pos.y is above me
	#	look for nearest stairs that lead up
	#
	# else is on the same floor, return
	pass

func _on_sight_area_body_entered(body: Node2D) -> void:
	#chase_target = body
	is_player_on_sight = true
	
func _on_sight_area_body_exited(body: Node2D) -> void:
	is_player_on_sight = false
	player_last_pos = body.global_position
	ray_cast.target_position = Vector2.ZERO
	
	if detected_obstacle():
		return
	
	set_state(States.SEARCH)

func _on_interact_area_area_entered(area: Area2D) -> void:
	#print("Enemy on stairs!")
	interaction_target = area.get_parent()
	#print(interaction_target.name)
	can_interact = true

func _on_interact_area_area_exited(area: Area2D) -> void:
	interaction_target = null
	can_interact = false

func _on_suspicion_timer_timeout() -> void:
	set_state(States.CHASE)

func _on_roaming_timer_timeout() -> void:
	var roaming_offset = Vector2(randf_range(-250, 250), 0)
	target_position = global_position + roaming_offset
	
	if global_position.distance_to(target_position) < 100:
		target_position = global_position
		velocity = Vector2.ZERO
	
	roaming_timer.wait_time = randf_range(min_wait, max_wait)

func _on_search_timer_timeout() -> void:
	set_state(States.ROAMING)

func _on_search_location_timer_timeout() -> void:
	var search_offset = Vector2(randf_range(-250, 250), 0)
	target_position = player_last_pos + search_offset
	
	if global_position.distance_to(target_position) < 100:
		target_position = global_position
		velocity = Vector2.ZERO
	
	#search_timer.wait_time = randf_range(min_wait, max_wait)

func _on_interaction_timer_timeout() -> void:
	#print("can interact again!")
	just_interacted = false
	#can_interact = true
