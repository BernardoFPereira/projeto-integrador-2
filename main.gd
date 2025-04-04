extends Node

# TODO: CHANGE THIS INSANE PARENTING
@onready var objective_label: Label = $Camera2D/CanvasLayer3/UI/ObjectiveLabel
@onready var interaction_label: Label = $Camera2D/CanvasLayer3/UI/InteractionLabel
@onready var ammo_label: Label = $Camera2D/CanvasLayer3/UI/AmmoLabel
@onready var objective_image: TextureRect = $Camera2D/CanvasLayer3/UI/ObjectiveImage

@onready var win_menu: Control = $Camera2D/CanvasLayer3/UI/WinMenu

func _ready() -> void:
	PlayerManager.player = get_tree().get_first_node_in_group("Player")

func _process(delta: float) -> void:
	if PlayerManager.player.carried_weapon:
		ammo_label.visible = true
		var max_ammo = PlayerManager.player.carried_weapon.max_ammo
		var current_ammo = PlayerManager.player.carried_weapon.current_ammo
		
		ammo_label.text = "%/%".format([max_ammo, current_ammo], "%")
	else:
		ammo_label.visible = false
		
	if PlayerManager.can_interact:
		interaction_label.visible = true
	else:
		interaction_label.visible = false
	
	if PlayerManager.briefcase_found:
		objective_image.visible = true
		objective_label.text = "Você encontrou a maleta!\nVá até o poste para completar a missão."

func _on_button_pressed() -> void:
	PlayerManager.is_player_dead = false
	PlayerManager.briefcase_found = false
	get_tree().change_scene_to_file("res://test_level.tscn")

func _on_inside_area_body_entered(body: Node2D) -> void:
	PlayerManager.is_inside = true

func _on_inside_area_body_exited(body: Node2D) -> void:
	PlayerManager.is_inside = false

func _on_map_exit_area_body_entered(body: Node2D) -> void:
	if PlayerManager.briefcase_found:
		PlayerManager.game_complete = true
		win_menu.visible = true

func _on_button_3_pressed() -> void:
	get_tree().quit()

func _on_button_2_pressed() -> void:
	PlayerManager.game_complete = false
	PlayerManager.briefcase_found = false
	get_tree().reload_current_scene()
