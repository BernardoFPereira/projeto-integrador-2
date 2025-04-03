extends Node2D

@export var connected_lights: Array[Node2D]

@onready var line_2d: Line2D = $Line2D

func interaction():
	Audio.play("res://Sounds/FX/metalLatch.ogg", -10)
	if connected_lights:
		for light in connected_lights:
			light.switch_power()

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		PlayerManager.can_interact = true
		line_2d.visible = true
		PlayerManager.interact_target = self

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		line_2d.visible = false
		if PlayerManager.interact_target == self:
			PlayerManager.can_interact = false
			PlayerManager.interact_target = null
