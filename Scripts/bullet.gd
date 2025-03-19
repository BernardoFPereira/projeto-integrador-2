extends AnimatableBody2D

var BULLET_SPEED := 4000
var IMPACT := 250
var targ_dir := Vector2.ZERO

func _ready() -> void:
	targ_dir = global_position.direction_to(get_global_mouse_position() + Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0)))

func _physics_process(delta: float) -> void:
	var collision = move_and_collide((BULLET_SPEED * targ_dir) * delta)
	#var debug = preload("res://Scenes/collision_marker.tscn").instantiate()
	
	if collision:
		var collision_fx = preload("res://Scenes/bullet_impact.tscn").instantiate()
		
		var spawn_pos = collision.get_position()
		var collision_norm = collision.get_normal()
		
		collision_fx.global_transform.origin = spawn_pos
		collision_fx.look_at(spawn_pos + collision_norm)
		
		get_tree().root.add_child(collision_fx)
		
		var collider = collision.get_collider()
		if collider.is_class("CharacterBody2D"):
			var shape = collision.get_collider_shape()
			if shape.is_in_group("HeadCollider"):
				collider.health_points -= 2
			if shape.is_in_group("BodyCollider"):
				collider.health_points -= 1
			#collider.apply_impulse(targ_dir * IMPACT)
		
		self.queue_free()
