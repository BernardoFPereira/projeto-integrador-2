extends Control

var cursor_arrow = load("res://Sprites/UI/cursors/cursores1.png")
var cursor_arrow_clicked = load("res://Sprites/UI/cursors/cursores2.png")

func _ready() -> void:
	Input.set_custom_mouse_cursor(cursor_arrow)

func _on_button_start_game_pressed() -> void:
	Audio.play("res://Audio/FX/metalLatch.ogg", -15)
	SceneManager.change_scene("res://Scenes/Levels/tutorial_level.tscn")
	#get_tree().change_scene_to_file("res://Scenes/Levels/test_level.tscn")

func _on_button_options_pressed() -> void:
	Audio.play("res://Audio/FX/metalLatch.ogg", -15)
	SceneManager.change_scene("res://Scenes/Menus/OptionsMenu.tscn")
	#get_tree().change_scene_to_file("res://Scenes/Menus/OptionsMenu.tscn")

func _on_button_credits_pressed() -> void:
	Audio.play("res://Audio/FX/metalLatch.ogg", -15)
	SceneManager.change_scene("res://Scenes/Menus/CreditsMenu.tscn")
	#get_tree().change_scene_to_file("res://Scenes/Menus/CreditsMenu.tscn")

func _on_button_quit_pressed() -> void:
	Audio.play("res://Audio/FX/metalLatch.ogg", -15)
	get_tree().quit()
