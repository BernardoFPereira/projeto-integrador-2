extends RigidBody2D

enum States { IDLE, SUSPICIOUS, CHASE, ATTACK }

var state: States
var player_last_pos: Vector2

func _ready() -> void:
	state = States.IDLE

func _physics_process(delta: float) -> void:
	handle_states()

func set_state(new_state: States) -> void:
	pass

func handle_states() -> void:
	match state:
		States.IDLE:
			#if algo_acontece:
				#set_state(States.SUSPICIOUS)
			pass
		States.SUSPICIOUS:
			pass
		States.CHASE:
			pass
		States.ATTACK:
			pass
	
