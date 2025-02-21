extends Node2D
class_name stairs

@export var destination: Node2D
@onready var spawn_marker: Marker2D = $Marker2D

var object_to_interact: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func interaction():
	object_to_interact.global_position = destination.spawn_marker.global_position
	pass

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		PlayerManager.can_interact = true
		PlayerManager.interact_target = self
		object_to_interact = body



func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if PlayerManager.interact_target == self:
			PlayerManager.can_interact = false
			PlayerManager.interact_target = null
