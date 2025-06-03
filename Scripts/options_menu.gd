extends Control

var cursor_arrow = load("res://Sprites/UI/cursors/cursores1.png")
var cursor_arrow_clicked = load("res://Sprites/UI/cursors/cursores2.png")

func _ready() -> void:
	Input.set_custom_mouse_cursor(cursor_arrow)

func _on_button_back_pressed() -> void:
	SceneManager.change_scene("res://Scenes/Menus/MainMenu.tscn")
	#get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu.tscn")

func _on_button_back_button_down() -> void:
	Audio.play("res://Audio/FX/ui_button_click.ogg", 0)
