extends CheckButton

func _ready() -> void:
	var mode := DisplayServer.window_get_mode()
	match mode:
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			set_pressed_no_signal(true)
		_:
			set_pressed_no_signal(false)

func _process(delta: float) -> void:
	var mode := DisplayServer.window_get_mode()
	var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
	
	match is_window:
		false:
			set_pressed_no_signal(true)
			#text = "on"
		true:
			set_pressed_no_signal(false)
			#text = "off"

func _on_toggled(toggled_on: bool) -> void:
	var mode := DisplayServer.window_get_mode()
	var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_window else DisplayServer.WINDOW_MODE_WINDOWED)
