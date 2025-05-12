extends Control

func _on_button_start_game_pressed() -> void:
	SceneManager.change_scene("res://Scenes/Levels/tutorial_level.tscn")
	#get_tree().change_scene_to_file("res://Scenes/Levels/test_level.tscn")

func _on_button_options_pressed() -> void:
	SceneManager.change_scene("res://Scenes/Menus/OptionsMenu.tscn")
	#get_tree().change_scene_to_file("res://Scenes/Menus/OptionsMenu.tscn")

func _on_button_credits_pressed() -> void:
	SceneManager.change_scene("res://Scenes/Menus/CreditsMenu.tscn")
	#get_tree().change_scene_to_file("res://Scenes/Menus/CreditsMenu.tscn")

func _on_button_quit_pressed() -> void:
	get_tree().quit()
