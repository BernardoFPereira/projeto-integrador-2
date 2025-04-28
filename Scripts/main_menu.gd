extends Control

func _on_button_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://test_level.tscn")

func _on_button_options_pressed() -> void:
	# Load Option Menu Scene
	pass # Replace with function body.

func _on_button_credits_pressed() -> void:
	# Load Credits Scene
	pass # Replace with function body.

func _on_button_quit_pressed() -> void:
	get_tree().quit()
