extends Node2D
class_name stairs

enum Direction { UP, DOWN }

@export var destination: Node2D
@export var direction: Direction

@onready var spawn_marker: Marker2D = $Marker2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var object_to_move: Node2D
var enemy_to_move: Node2D

func _ready() -> void:
	match direction:
		Direction.UP:
			animated_sprite.flip_v = true
			pass
		Direction.DOWN:
			pass

func interaction(mode: String = "PLAYER"):
	match mode:
		"PLAYER":
			if object_to_move != null:
				object_to_move.global_position = destination.spawn_marker.global_position
				object_to_move.velocity = Vector2.ZERO
				object_to_move = null
			
		"ENEMY":
			if enemy_to_move != null:
				enemy_to_move.global_position = destination.spawn_marker.global_position
				enemy_to_move.velocity = Vector2.ZERO
				enemy_to_move = null

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		animated_sprite.visible = true
		PlayerManager.target_stairs = self
		object_to_move = body

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		animated_sprite.visible = false
		object_to_move = null

func _on_interact_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnemyInteractionArea"):
		#print("Enemy on stairs!")
		var enemy = area.get_parent()
		enemy_to_move = enemy

func _on_interact_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("EnemyInteractionArea"):
		enemy_to_move = null
