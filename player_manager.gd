extends Node2D

var possible_interactions: Array[Node2D]
var interact_target: Node2D
var can_interact := false
var target_stairs: Node2D

var light_target: Node2D
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

var game_complete := false

func restart() -> void:
	scanning_light = false
	is_in_shadow = true
	is_in_duct = false
	is_inside = false
	is_aiming = false
	can_shadowmeld = false
	can_shadowshot = false
	is_player_dead = false
	briefcase_found = false
	game_complete = false

func switch_aim(value):
	if is_aiming != value:
		is_aiming = !is_aiming

func set_in_shadow(value):
	if is_in_shadow != value:
		is_in_shadow = !is_in_shadow

func deal_damage(target, value):
	#var blood_spatter = preload("res://Scenes/blood_spatter.tscn").instantiate()
	if target.is_in_group("Player"):
		if !is_in_shadow:
			target.health -= value * 2
			return
		
	target.health -= value
	
	#var spatter_offset = Vector2(randf_range(-0.5,0.5), randf_range(-0.5,-0.5))
	#blood_spatter.global_position = target.global_position + spatter_offset
	#get_tree().get_first_node_in_group("BackWall").add_child(blood_spatter)
