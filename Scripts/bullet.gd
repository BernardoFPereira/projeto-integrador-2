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
			var blood_spatter = preload("res://Scenes/blood_spatter.tscn").instantiate()
			var shape = collision.get_collider_shape()
			
			if shape.is_in_group("HeadCollider"):
				Audio.play("res://Audio/FX/ImpactMeat02.ogg", -15)
				PlayerManager.deal_damage(collider, 2)
			
			if shape.is_in_group("BodyCollider"):
				Audio.play("res://Audio/FX/qubodupPunch02.ogg", -10)
				PlayerManager.deal_damage(collider, 1)
			
			# Spawn blood spatter
			blood_spatter.global_position = collision.get_position()
			get_tree().get_first_node_in_group("BackWall").add_child(blood_spatter)
		else:
			Audio.play("res://Audio/FX/ImpactStone.ogg", -15)
		
		self.queue_free()
