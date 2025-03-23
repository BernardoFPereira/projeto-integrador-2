extends Node2D

var interact_target: Node2D
var can_interact := false

var light_target: Light2D
var current_duct_pos: Vector2

var scanning_light := false
var is_in_shadow := true
var is_in_duct := false

var is_aiming := false

var can_shadowmeld := false
var can_shadowshot := false

var is_shadow_meld

var player: Player
#var is_player_dead := false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func switch_aim(value):
	if is_aiming != value:
		is_aiming = !is_aiming

func set_in_shadow(value):
	if is_in_shadow != value:
		is_in_shadow = !is_in_shadow

func deal_damage(value):
	if is_in_shadow:
		player.health -= value
	else:
		player.health -= value * 2
