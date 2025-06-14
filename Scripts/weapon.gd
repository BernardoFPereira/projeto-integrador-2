extends RigidBody2D
class_name Weapon

@export var weapon_name: String
@export var weapon_icon: Texture2D
@export var default_sprite: Texture2D
@export var held_sprite: Texture2D
@export var used_sprite: Texture2D

@export_enum("melee", "ranged") var weapon_type: String
@export var max_ammo: int = 0
@export var current_ammo: int

@onready var interact_area: Area2D = $InteractArea
@onready var highlight: Sprite2D = $Highlight

@onready var sound_range: Area2D = $SoundRange
#@onready var interact_highlight: Polygon2D = $InteractHighlight
@onready var interaction_timer: Timer = $InteractionTimer

@onready var sound_attack: AudioStreamPlayer = $SoundAttack
@onready var pickup_sound: AudioStreamPlayer = $SoundPickup

@onready var sprite = $Sprite2D

var player: Player
var muzzle: Marker2D

var was_thrown := false


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	#current_ammo = max_ammo
	default_sprite = sprite.texture
	
	var muz = get_node("Muzzle")
	if muz:
		muzzle = muz
	else:
		muzzle = null

#func _process(delta) -> void:
	#if PlayerManager.player.carried_weapon != self:
		#if global_position.distance_to(player.global_position) < 70:
			#PlayerManager.can_interact = true
			#PlayerManager.interact_target = self
		#else:
			#PlayerManager.can_interact = false
			#PlayerManager.interact_target = null

func interaction() -> void:
	player = get_tree().get_first_node_in_group("Player")
	$PickupHint.visible = false
	#default_sprite = sprite.texture
	PlayerManager.possible_interactions = PlayerManager.possible_interactions.filter(
		func(node): return node != self
	)
	if player.carried_weapon != null:
		drop_weapon()
	
	can_sleep = false
	
	sprite.texture = held_sprite
	var hand_hold_spot = player.hand.find_child("HoldSpot")
	reparent(player.hand)
	player.carried_weapon = self
	freeze = true
	transform = hand_hold_spot.transform
	rotation = 0.0
	interact_area.monitoring = false
	highlight.visible = false
	interact_area.set_collision_layer_value(11, 0)
	
	pickup_sound.play()
	#print(weapon_type)
	
func drop_weapon() -> void:
	var weapon = player.carried_weapon
	weapon.sprite.texture = weapon.default_sprite
	weapon.freeze = false
	weapon.reparent(get_tree().get_first_node_in_group("Main"))
	weapon.interact_area.monitoring = true
	weapon.interact_area.set_collision_layer_value(11, 1)
	weapon.highlight.visible = true
	
	player.carried_weapon = null
	sleeping = false

func melee(targets_to_hit: Array) -> void:
	match weapon_type:
		"melee":
			for target: Enemy in targets_to_hit:
				var inside_area = get_tree().get_first_node_in_group("Indoors").get_child(0)
				var back_wall = get_tree().get_first_node_in_group("BackWall")
				
				if Geometry2D.is_point_in_polygon(target.global_position, inside_area.polygon):
					var blood_spatter = preload("res://Scenes/FX/blood_spatter.tscn").instantiate()
					blood_spatter.global_position = global_position
					back_wall.add_child(blood_spatter)
					
				PlayerManager.deal_damage(target, 2)
				target.set_state(target.States.DAMAGE)
				Audio.play("res://Audio/FX/knife_hit.ogg", -15)
			
		_:
			for target: Enemy in targets_to_hit:
				PlayerManager.deal_damage(target, 1)
				Audio.play("res://Audio/FX/qubodupPunch02.ogg", -5)
				target.set_state(target.States.DAMAGE)
	#print(target_to_hit)

func throw() -> void:
	sprite.texture = default_sprite
	interact_area.set_collision_layer_value(11, 1)
	var impulse = global_position.direction_to(get_global_mouse_position()) * player.throw_power
	player.carried_weapon = null
	freeze = false
	was_thrown = true
	reparent(get_tree().get_first_node_in_group("Main"))
	apply_impulse(impulse)
	apply_torque(35000.0)
	set_collision_mask_value(13, 1)

func shoot() -> void:
	if current_ammo > 0:
		broadcast_noise()
		var muzzle_flash_fx = preload("res://Scenes/FX/muzzle_flash_fx.tscn").instantiate()
		var muzzle_flash = preload("res://Scenes/FX/muzzle_flash.tscn").instantiate()
		var projectile = preload("res://Scenes/Weapons/bullet.tscn").instantiate()
		
		var dir = muzzle.global_position.direction_to(get_global_mouse_position())
		
		# Point projectile towards target
		projectile.look_at(get_global_mouse_position())
		
		# Spawn projectile
		muzzle_flash_fx.global_transform = muzzle.global_transform
		muzzle_flash_fx.scale = scale
		
		muzzle_flash_fx.rotate(deg_to_rad(90))
		muzzle_flash.global_transform = muzzle.global_transform
		projectile.global_transform = muzzle.global_transform
		
		get_tree().root.add_child(muzzle_flash_fx)
		get_tree().root.add_child(muzzle_flash)
		get_tree().root.add_child(projectile)
		current_ammo -= 1
		
		sound_attack.play()

func broadcast_noise() -> void:
	var bodies_in_range = sound_range.get_overlapping_bodies()
	if bodies_in_range:
		for body in bodies_in_range:
			if body.state != body.States.DEAD:
				if !body.is_deaf:
					body.heard_noise = true
					body.player_last_pos = player.global_position

func flip_weapon() -> void:
	match player.facing:
		player.Facing.RIGHT:
			scale.y = 1
			muzzle.scale.x = 1
		player.Facing.LEFT:
			scale.y = -1
			muzzle.scale.x = -1

#func _on_interact_area_body_entered(body: Node2D) -> void:
	#match body.get_class():
		#"CharacterBody2D":
			#PlayerManager.can_interact = true
			#PlayerManager.interact_target = self
			#player = body
		#_:
			#pass

#func _on_interact_area_body_exited(body: Node2D) -> void:
	#match body.get_class():
		#"CharacterBody2D":
			#PlayerManager.can_interact = false
			#PlayerManager.interact_target = null
		#_:
			#pass

func _on_body_entered(body: Node) -> void:
	if was_thrown:
		print("collided!")
		set_collision_mask_value(13, 0)
		was_thrown = !was_thrown
		
		if body.is_in_group("Enemy"):
			PlayerManager.deal_damage(body, 2)
			var inside_area = get_tree().get_first_node_in_group("Indoors").get_child(0)
			
			if Geometry2D.is_point_in_polygon(global_position, inside_area.polygon):
				var blood_spatter = preload("res://Scenes/FX/blood_spatter.tscn").instantiate()
				var back_wall = get_tree().get_first_node_in_group("BackWall")
				blood_spatter.global_position = global_position
				back_wall.add_child(blood_spatter)
				
			Audio.play("res://Audio/FX/ImpactMeat01.ogg", -15)
			interact_area.set_collision_layer_value(11,0)
			sprite.texture = used_sprite
			return
		
		interact_area.monitoring = true
		highlight.visible = true

func _on_interaction_timer_timeout() -> void:
	print("weapon timer")
