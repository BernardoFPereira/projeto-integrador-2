extends HSlider

@export var audio_bus_name := "Master"

@onready var _bus := AudioServer.get_bus_index(audio_bus_name)

func _ready() -> void:
	value = db_to_linear(AudioServer.get_bus_volume_db(_bus))

func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(_bus, linear_to_db(value))

func _on_drag_ended(_value_changed: bool) -> void:
	if audio_bus_name in ["Master", "SoundFX"]:
		Audio.play("res://Audio/FX/cloth3.ogg", 0)

func _on_mouse_exited() -> void:
	release_focus()
