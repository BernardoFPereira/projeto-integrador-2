extends Node

@onready var door: Node2D = $Level/Doors/Door
@onready var player: Player = $Player
@onready var interaction: Label = $Debug/Interaction
@onready var interaction_target: Label = $Debug/InteractionTarget
@onready var is_in_shadow: Label = $Debug/IsInShadow
@onready var is_aiming: Label = $Debug/IsAiming
@onready var state: Label = $Debug/State
@onready var state_2: Label = $Debug/State2
@onready var ammo_count: Label = $Debug/AmmoCount

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#door.open_door()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Debug text updates
	var can_interact = PlayerManager.can_interact
	var target = PlayerManager.interact_target.name if PlayerManager.interact_target else "none"
	var in_shadow = PlayerManager.is_in_shadow
	var char_is_aiming = PlayerManager.is_aiming
	var in_duct = PlayerManager.is_in_duct
	
	interaction.text = "can_interact: %s" % can_interact
	interaction_target.text = "interaction_target: %s" % target
	is_in_shadow.text = "is_in_shadow: %s" % in_shadow
	is_aiming.text = "is_aiming: %s" % char_is_aiming
	state.text = "state: %s" % player.States.keys()[player.state]
	
	if player.carried_weapon:
		var max_ammo = str(player.carried_weapon.max_ammo)
		var current_ammo = str(player.carried_weapon.current_ammo)
		state_2.text = "last_state: %s" % player.States.keys()[player.last_state]
		ammo_count.text = "ammo_count: " + current_ammo + "/" + max_ammo
	else:
		ammo_count.text = "none"
