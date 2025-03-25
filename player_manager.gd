extends Node2D

var interact_target: Node2D
var can_interact := false

var light_target: Light2D
var current_duct_pos: Vector2

var scanning_light := false
var is_in_shadow := true
var is_in_duct := false
var is_inside := false

var is_aiming := false

var can_shadowmeld := false
var can_shadowshot := false

var is_shadow_meld

var player: Player
var is_player_dead := false

var briefcase_found := false

func switch_aim(value):
	if is_aiming != value:
		is_aiming = !is_aiming

func set_in_shadow(value):
	if is_in_shadow != value:
		is_in_shadow = !is_in_shadow

func deal_damage(target, value):
	if target.is_in_group("Player"):
		if !is_in_shadow:
			target.health -= value * 2
			return
	
	target.health -= value
	
