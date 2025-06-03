extends Control

@export var left_spawn: Marker2D
@export var right_spawn: Marker2D
@export var left_target: Marker2D
@export var right_target: Marker2D

@onready var grunts: Node = $"../Grunts"
@onready var timer: Timer = $"../Timer"

func _on_button_main_menu_pressed() -> void:
	SceneManager.change_scene("res://Scenes/Menus/MainMenu.tscn")

func _on_button_main_menu_button_down() -> void:
	Audio.play("res://Audio/FX/ui_button_click.ogg", 0)

func _on_left_side_body_entered(body: Node2D) -> void:
	body.queue_free()

func _on_screen_size_body_entered(body: Node2D) -> void:
	body.queue_free()

func _on_timer_timeout() -> void:
	var enemy_to_spawn = randi_range(0,6)
	var where_to_spawn = randi_range(0,1)
	
	var enemy_instance: Enemy
	
	if enemy_to_spawn % 2 != 0:
		enemy_instance = preload("res://Scenes/Entities/enemy_melee.tscn").instantiate()
	else:
		enemy_instance = preload("res://Scenes/Entities/enemy_ranged.tscn").instantiate()
		
	match where_to_spawn:
		0:
			enemy_instance.transform = right_spawn.transform
			#enemy_instance.state = enemy_instance.States.MOVE_TO_TARGET
			enemy_instance.facing = enemy_instance.Facing.LEFT
			enemy_instance.target_position = left_target.global_position
		1:
			enemy_instance.transform = left_spawn.transform
			enemy_instance.facing = enemy_instance.Facing.RIGHT
			enemy_instance.target_position = right_target.global_position
		
	enemy_instance.start_state = enemy_instance.States.MOVE_TO_TARGET
	timer.wait_time = randf_range(1.5, 4.0)
	grunts.add_child(enemy_instance)
