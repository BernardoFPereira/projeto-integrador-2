extends CheckButton

func _process(delta: float) -> void:
	var mode := DisplayServer.window_get_mode()
	
	match mode:
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			text = "on"
		_:
			text = "off"

func _on_toggled(toggled_on: bool) -> void:
	var mode := DisplayServer.window_get_mode()
	var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_window else DisplayServer.WINDOW_MODE_WINDOWED)
