extends Control

func _on_button_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu.tscn")
