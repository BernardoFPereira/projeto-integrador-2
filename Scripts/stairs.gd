extends Node2D
class_name stairs

enum Direction { UP, DOWN }

@export var destination: Node2D
@export var direction: Direction

@onready var spawn_marker: Marker2D = $Marker2D

var object_to_move: Node2D
var enemy_to_move: Node2D

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
				
func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		PlayerManager.target_stairs = self
		#PlayerManager.can_interact = true
		#PlayerManager.interact_target = self
		object_to_move = body

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		PlayerManager.target_stairs = null
		#if PlayerManager.interact_target == self:
			#PlayerManager.can_interact = false
			#PlayerManager.interact_target = null
		#object_to_move = null
	
	#if body.is_in_group("Enemy"):
		#if body.interaction_target == self:

func _on_interact_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnemyInteractionArea"):
		print("Enemy on stairs!")
		var enemy = area.get_parent()
		#enemy.can_interact = true
		#enemy.interaction_target = self
		enemy_to_move = enemy
		#print("switching stairs target")

func _on_interact_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("EnemyInteractionArea"):
		#var enemy = area.get_parent()
		
		#enemy.can_interact = false
		#enemy.interaction_target = null
		enemy_to_move = null
