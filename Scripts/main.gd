extends Node

@onready var objective_label: Label = $CanvasLayer3/UI/ObjectiveLabel
@onready var interaction_label: Label = $CanvasLayer3/UI/InteractionLabel
@onready var ammo_label: Label = $CanvasLayer3/UI/AmmoLabel
@onready var carried_weapon: TextureRect = $CanvasLayer3/UI/CarriedWeapon
@onready var objective_image: TextureRect = $CanvasLayer3/UI/ObjectiveImage

@onready var win_menu: Control = $CanvasLayer3/UI/WinMenu
@onready var lose_menu: Control = $CanvasLayer3/UI/LoseMenu
@onready var pause_menu: Control = $CanvasLayer3/UI/PauseMenu
@onready var mission_box: Control = $CanvasLayer3/UI/MissionBox
@onready var mission_box_player: AnimationPlayer = $CanvasLayer3/UI/MissionBox/MissionBoxPlayer

var objective_complete := false

func _ready() -> void:
	PlayerManager.player = get_tree().get_first_node_in_group("Player")

func _process(delta: float) -> void:
	if PlayerManager.player.carried_weapon:
		carried_weapon.texture = PlayerManager.player.carried_weapon.weapon_icon
		ammo_label.visible = true
		var max_ammo = PlayerManager.player.carried_weapon.max_ammo
		var current_ammo = PlayerManager.player.carried_weapon.current_ammo
		
		ammo_label.text = "%/%".format(
			[max_ammo, current_ammo], "%"
			) if max_ammo > 0 else ""
	else:
		ammo_label.visible = false
		carried_weapon.texture = null
		
	if PlayerManager.can_interact:
		interaction_label.visible = true
	else:
		interaction_label.visible = false
	
	if PlayerManager.briefcase_found and !objective_complete:
		mission_box_player.play("mission_1_complete")
		objective_complete = true
		objective_image.visible = true
		objective_label.text = "Você encontrou a maleta!\nVá até o poste para completar a missão."
	
	if PlayerManager.is_player_dead:
		lose_menu.visible = true

# debug mode restart
func _on_button_pressed() -> void:
	PlayerManager.restart()
	get_tree().change_scene_to_file("res://Scenes/Levels/test_level.tscn")

func _on_map_exit_area_body_entered(body: Node2D) -> void:
	if objective_complete:
		PlayerManager.game_complete = true
		win_menu.visible = true

func _on_button_quit_pressed() -> void:
	get_tree().quit()

func _on_button_try_again_pressed() -> void:
	PlayerManager.restart()
	get_tree().reload_current_scene()

func _on_inside_area_body_exited(body: Node2D) -> void:
	PlayerManager.is_inside = false

func _on_button_continue_pressed() -> void:
	get_tree().paused = false
	pause_menu.visible = false

func _on_button_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu.tscn")

func play_mission_complete_audio() -> void:
	Audio.play("res://Audio/FX/mission_win.ogg", 0)

#func _on_mission_box_player_animation_finished(anim_name: StringName) -> void:
	#mission_box_player.play("idle")
