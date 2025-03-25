extends RigidBody2D
class_name Weapon

@export_enum("melee", "ranged") var weapon_type: String
@export var max_ammo: int = 0

@onready var interact_area: Area2D = $InteractArea
@onready var sound_range: Area2D = $SoundRange
#@onready var interact_highlight: Polygon2D = $InteractHighlight
@onready var interaction_timer: Timer = $InteractionTimer

var player: Player
var muzzle: Marker2D
var current_ammo: int

var was_thrown := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	current_ammo = max_ammo
	
	var muz = get_node("Muzzle")
	if muz:
		muzzle = muz
	else:
		muzzle = null

func interaction() -> void:
	if player.carried_weapon != null:
		drop_weapon()
	
	can_sleep = false
	
	var hand_hold_spot = player.hand.find_child("HoldSpot")
	reparent(player.hand)
	player.carried_weapon = self
	freeze = true
	#sleeping = true
	transform = hand_hold_spot.transform
	rotation = 0.0
	interact_area.monitoring = false
	#print(weapon_type)
	
func drop_weapon() -> void:
	var weapon = player.carried_weapon
	weapon.freeze = false
	weapon.reparent(get_tree().root)
	weapon.interact_area.monitoring = true
	player.carried_weapon = null
	sleeping = false

func melee(targets_to_hit: Array) -> void:
	match weapon_type:
		"melee":
			#var slash_fx = preload("res://Scenes/enemy_slash.tscn").instantiate()
			#slash_fx.transform = get_tree().get_first_node_in_group("Player").transform
			#get_tree().root.add_child(slash_fx)
			
			for target: Enemy in targets_to_hit:
				target.set_state(target.States.DEAD)
		"ranged":
			#var punch_fx = preload("res://Scenes/enemy_slash.tscn").instantiate()
			#punch_fx.transform = get_tree().get_first_node_in_group("Player").transform
			#get_tree().root.add_child(punch_fx)
			
			for target: Enemy in targets_to_hit:
				PlayerManager.deal_damage(target, 1)
	#print(target_to_hit)
	#player.set_state(player.States.IDLE)

func throw() -> void:
	var impulse = global_position.direction_to(get_global_mouse_position()) * player.throw_power
	player.carried_weapon = null
	freeze = false
	was_thrown = true
	#interaction_timer.start()
	#interact_area.monitoring = true
	reparent(get_tree().root)
	apply_impulse(impulse)
	apply_torque(35000.0)
	set_collision_mask_value(13, 1)

func shoot() -> void:
	broadcast_noise()
	if current_ammo > 0:
		var muzzle_flash_fx = preload("res://Scenes/muzzle_flash_fx.tscn").instantiate()
		var muzzle_flash = preload("res://Scenes/muzzle_flash.tscn").instantiate()
		var projectile = preload("res://Scenes/Weapons/bullet.tscn").instantiate()
		
		var dir = muzzle.global_position.direction_to(get_global_mouse_position())
		
		# Point projectile towards target
		projectile.look_at(get_global_mouse_position())
		
		# Spawn projectile
		muzzle_flash_fx.global_transform = muzzle.global_transform
		muzzle_flash_fx.rotate(deg_to_rad(90))
		muzzle_flash.global_transform = muzzle.global_transform
		projectile.global_transform = muzzle.global_transform
		
		get_tree().root.add_child(muzzle_flash_fx)
		get_tree().root.add_child(muzzle_flash)
		get_tree().root.add_child(projectile)
		current_ammo -= 1

func broadcast_noise() -> void:
	var bodies_in_range = sound_range.get_overlapping_bodies()
	if bodies_in_range:
		for body in bodies_in_range:
			if body.state != body.States.DEAD:
				body.player_last_pos = player.global_position
				body.set_state(body.States.SEARCH)

func _on_interact_area_body_entered(body: Node2D) -> void:
	match body.get_class():
		"CharacterBody2D":
			PlayerManager.can_interact = true
			PlayerManager.interact_target = self
			player = body
		_:
			pass

func _on_interact_area_body_exited(body: Node2D) -> void:
	match body.get_class():
		"CharacterBody2D":
			PlayerManager.can_interact = false
			PlayerManager.interact_target = null
		_:
			pass

func _on_body_entered(body: Node) -> void:
	if was_thrown:
		print("collided!")
		was_thrown = !was_thrown
		set_collision_mask_value(13, 0)
		interact_area.monitoring = true
		if body.is_in_group("Enemy"):
			PlayerManager.deal_damage(body, 2)

func _on_interaction_timer_timeout() -> void:
	print("weapon timer")
