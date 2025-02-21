extends Node2D
class_name Vent

@export var entry_point: VentWaypoint
@export var on_wall := false
@export var is_exit := false

@onready var line_2d: Line2D = $Line2D

var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
#
func interaction():
	print("Interacting with vent!")
	pass

func _on_interact_area_body_entered(body: Node2D) -> void:
	line_2d.visible = true
	PlayerManager.can_interact = true
	PlayerManager.interact_target = self

func _on_interact_area_body_exited(body: Node2D) -> void:
	line_2d.visible = false
	PlayerManager.can_interact = false
	PlayerManager.interact_target = null
