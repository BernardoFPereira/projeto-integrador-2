extends Line2D

@onready var shadow_shot_collision = $"../ShadowShotCollision"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

#func _draw() -> void:
	#draw_line(position, get_local_mouse_position(), Color.GHOST_WHITE, 2.0)

func update_trajectory(dir: Vector2, speed: float, gravity: float, delta: float) -> void:
	var max_points = 42
	clear_points()
	var pos: Vector2 = Vector2.ZERO + (position.direction_to(get_local_mouse_position()) * 18)
	var vel = dir * speed
	#var vel = dir * PlayerManager.shadowshot_speed
	for i in max_points:
		add_point(pos)
		#var space_state = get_world_2d().direct_space_state
		## use global coordinates, not local to node
		#var query = PhysicsRayQueryParameters2D.create(Vector2(0, 0), Vector2(50, 100))
		#var collision: Dictionary = space_state.intersect_ray(query)
		##var collision = shadow_shot_collision.move_and_collide(vel * delta, false, true)
		#vel.y += gravity * delta
		#
		#if collision.find_key("collider"):
			#PlayerManager.can_shadowshot = true
			#break
		#
		pos += vel * delta
		#shadow_shot_collision.position = pos
