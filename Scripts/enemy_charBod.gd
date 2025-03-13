extends CharacterBody2D
class_name Enemy

enum States { IDLE, SUSPICIOUS, CHASE, ATTACK, ROAMING }
enum Facing { LEFT, RIGHT }

@export var facing: Facing
@export var speed := 100.0

@onready var ray_cast: RayCast2D = $RayCast
@onready var sight_area: Area2D = $SightArea
@onready var roaming_timer: Timer = $RoamingTimer

var state: States
var player_last_pos: Vector2

var chase_target: Node2D
var is_player_on_sight := false

var target_position := Vector2.ZERO

func _ready() -> void:
	state = States.IDLE

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * (delta * 2)
	
	handle_states(delta)
	handle_facing()
	#move_and_collide(global_position.direction_to(player_last_pos))
	
func set_investigation_target() -> void:
	pass

func set_state(new_state: States) -> void:
	if new_state != state:
		match new_state:
			States.ROAMING:
				print("start roming")
				roaming_timer.start()
				
			_:
				roaming_timer.stop()
				
		state = new_state

func set_facing(new_facing) -> void:
	if new_facing != facing:
		facing = new_facing

func handle_facing() -> void:
	match facing:
		Facing.LEFT:
			sight_area.scale.x = -1.0
		Facing.RIGHT:
			sight_area.scale.x = 1.0

func handle_states(delta) -> void:

	match state:
		States.IDLE:
			if is_player_on_sight:
				set_state(States.CHASE)
		
		States.SUSPICIOUS:
			pass
		
		States.CHASE:
			target_position = chase_target.global_position
			
			detect_obstacles()
			if !is_player_on_sight:
				set_state(States.ROAMING)
			
			var distance_to_player = global_position.distance_to(target_position)
			var direction_to_player = global_position.direction_to(chase_target.global_position)
			if distance_to_player < 50:
				set_state(States.ATTACK)
			
			velocity.x = lerpf(velocity.x, direction_to_player.x * speed, delta)
			
			move_and_slide()
			
		States.ATTACK:
			pass
			
		States.ROAMING:
			velocity.x = lerpf(velocity.x, global_position.direction_to(target_position).x * speed, delta)
			
			if is_player_on_sight:
				set_state(States.CHASE)
			
			move_and_slide()

func detect_obstacles() -> void:
	var target_distance = ray_cast.global_position.distance_to(chase_target.global_position)
	ray_cast.look_at(chase_target.global_position)
	ray_cast.target_position = Vector2(target_distance,0)
	ray_cast.force_raycast_update()
	
	var collision = ray_cast.get_collider()
	
	if collision:
		if collision.is_class("CharacterBody2D"):
			is_player_on_sight = true
		else:
			is_player_on_sight = false

func _on_sight_area_body_entered(body: Node2D) -> void:
	chase_target = body
	is_player_on_sight = true

func _on_roaming_timer_timeout() -> void:
	var roaming_offset = Vector2(randf_range(-300, 300), 0)
	target_position = global_position + roaming_offset
	
	if target_position.x > global_position.x:
		set_facing(Facing.RIGHT)
		pass
	elif target_position.x < global_position.x:
		set_facing(Facing.LEFT)
		pass

func _on_sight_area_body_exited(body: Node2D) -> void:
	is_player_on_sight = false
	chase_target = null
	set_state(States.ROAMING)
	pass # Replace with function body.
