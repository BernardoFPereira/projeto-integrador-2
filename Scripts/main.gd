extends Node

@onready var objective_box: Control = $CanvasLayer3/UI/ObjectiveBox
@onready var objective_label: RichTextLabel = $CanvasLayer3/UI/ObjectiveBox/ObjectiveLabel
@onready var objective_image: TextureRect = $CanvasLayer3/UI/ObjectiveBox/ObjectiveImage

@onready var interaction_box: Control = $CanvasLayer3/UI/InteractionBox
@onready var interaction_label: RichTextLabel = $CanvasLayer3/UI/InteractionBox/InteractionLabel

@onready var carried_weapon_box: Control = $CanvasLayer3/UI/CarriedWeaponBox
@onready var carried_weapon: TextureRect = $CanvasLayer3/UI/CarriedWeaponBox/CarriedWeaponSprite
@onready var ammo_label: Label = $CanvasLayer3/UI/CarriedWeaponBox/AmmoLabel

@onready var win_menu: Control = $CanvasLayer3/UI/WinMenu
@onready var lose_menu: Control = $CanvasLayer3/UI/LoseMenu
@onready var pause_menu: Control = $CanvasLayer3/UI/PauseMenu
@onready var mission_box: Control = $CanvasLayer3/UI/MissionBox
@onready var mission_box_player: AnimationPlayer = $CanvasLayer3/UI/MissionBox/MissionBoxPlayer

@onready var death_timer: Timer = $DeathTimer
@onready var win_timer: Timer = $WinTimer

var objective_complete := false

var cursor_arrow = load("res://Sprites/UI/cursors/cursores1.png")
var cursor_arrow_clicked = load("res://Sprites/UI/cursors/cursores2.png")
var cursor_aim = load("res://Sprites/UI/reticulo.png")

func _ready() -> void:
	Input.set_custom_mouse_cursor(cursor_aim)
	PlayerManager.player = get_tree().get_first_node_in_group("Player")

func _process(delta: float) -> void:
	if PlayerManager.player.carried_weapon:
		carried_weapon.texture = PlayerManager.player.carried_weapon.weapon_icon
		carried_weapon_box.visible = true
		var max_ammo = PlayerManager.player.carried_weapon.max_ammo
		var current_ammo = PlayerManager.player.carried_weapon.current_ammo
		
		ammo_label.text = "%/%".format(
			[current_ammo, max_ammo], "%"
			) if max_ammo > 0 else ""
	else:
		carried_weapon_box.visible = false
		carried_weapon.texture = null
		
	if PlayerManager.can_interact:
		interaction_box.visible = true
	else:
		interaction_box.visible = false
	
	if PlayerManager.briefcase_found and !objective_complete:
		mission_box_player.play("mission_1_complete")
		objective_complete = true
		objective_image.visible = true
		objective_label.text = "Você encontrou a maleta!"
	
	if PlayerManager.is_player_dead:
		if death_timer.is_stopped():
			death_timer.start()
		#lose_menu.visible = true

# debug mode restart
func _on_button_pressed() -> void:
	PlayerManager.restart()
	get_tree().change_scene_to_file("res://Scenes/Levels/test_level.tscn")

func _on_map_exit_area_body_entered(body: Node2D) -> void:
	if objective_complete:
		PlayerManager.game_complete = true
		
		if win_timer.is_stopped():
			win_timer.start()

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
	PlayerManager.restart()
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu.tscn")

func play_mission_complete_audio() -> void:
	Audio.play("res://Audio/FX/mission_win.ogg", -5)

func _on_button_restart_pressed() -> void:
	PlayerManager.restart()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_death_timer_timeout() -> void:
	#print("death timer time out!")
	lose_menu.visible = true
	
#func _on_mission_box_player_animation_finished(anim_name: StringName) -> void:
	#mission_box_player.play("idle")

func _on_win_timer_timeout() -> void:
	win_menu.visible = true
