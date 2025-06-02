extends Control

func _on_button_back_pressed() -> void:
	Audio.play("res://Audio/FX/ui_button_click.ogg", 0)
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu.tscn")
