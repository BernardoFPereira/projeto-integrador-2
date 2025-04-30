extends Node

@onready var pause_menu: Control = $"../CanvasLayer3/UI/PauseMenu"

var game_paused := false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		if game_paused:
			get_viewport().set_input_as_handled()
			game_paused = false
			pause_menu.visible = false
			get_tree().paused = false
		else:
			game_paused = true
			pause_menu.visible = true
			get_tree().paused = true

func _on_button_continue_pressed() -> void:
			game_paused = false
			pause_menu.visible = false
			get_tree().paused = false

func _on_button_quit_pressed() -> void:
	game_paused = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu.tscn")
	pass # Replace with function body.
