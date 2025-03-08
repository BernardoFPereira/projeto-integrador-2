extends RigidBody2D

@onready var ray_cast: RayCast2D = $RayCast

enum States { IDLE, SUSPICIOUS, CHASE, ATTACK, ROAMING }

var state: States
var player_last_pos: Vector2

var is_player_on_sight := false
var speed := 100

func _ready() -> void:
	state = States.IDLE

func _physics_process(delta: float) -> void:
	handle_states(delta)
	
func set_investigation_target() -> void:
	pass

func set_state(new_state: States) -> void:
	if new_state != state:
		state = new_state

func handle_states(delta) -> void:
	match state:
		States.IDLE:
			if is_player_on_sight:
				set_state(States.CHASE)
			pass
		States.SUSPICIOUS:
			pass
		States.CHASE:
			#var dir_to_player = global_position.direction_to(player_last_pos)
			global_position = lerp(global_position, player_last_pos, delta * 2)
			move_and_collide(player_last_pos)
			pass
		States.ATTACK:
			pass
		States.ROAMING:
			pass
	

func _on_sight_area_body_entered(body: Node2D) -> void:
	ray_cast.target_position = body.global_position
	ray_cast.force_raycast_update()
	
	var collision = ray_cast.get_collider()
	
	if collision:
		player_last_pos = body.global_position
		print("Player detected at %s!" % str(player_last_pos))
		is_player_on_sight = true
	pass # Replace with function body.
