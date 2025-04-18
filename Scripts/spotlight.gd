extends Node2D
class_name Light

@onready var light_pos_marker: Marker2D = $PointLight2D/LightPositionMarker
@onready var light_detect_area: Area2D = $PointLight2D/LightDetectArea
@onready var point_light_2d: Light = $"."

@export var is_on: bool = true
@export var lights: Array[Node2D]

var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	for light in lights:
		if is_on: 
			switch_power()
		if !is_on:
			switch_power()

func switch_power() -> void:
	for light in lights:
		is_on = !is_on
		light.enabled = !light.enabled
		light_detect_area.monitoring = !light_detect_area.monitoring

func _on_light_detect_area_body_entered(body: Node2D) -> void:
	match body.get_class():
		"CharacterBody2D":
			#looking_for_player = true
			PlayerManager.scanning_light = true
			PlayerManager.light_target = self
			print("scanning light area")
			print(PlayerManager.is_in_shadow)
		_:
			pass

func _on_light_detect_area_body_exited(body: Node2D) -> void:
	match body.get_class():
		"CharacterBody2D":
			#looking_for_player = false
			PlayerManager.scanning_light = false
			PlayerManager.light_target = null
			PlayerManager.set_in_shadow(true)
			print("not scanning anymore")
			print(PlayerManager.is_in_shadow)
		_:
			pass
