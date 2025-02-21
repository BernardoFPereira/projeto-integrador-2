extends RigidBody2D
class_name Weapon

@export_enum("melee", "ranged") var weapon_type: String
@onready var interact_area: Area2D = $InteractArea

var was_thrown := false
var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func interaction() -> void:
	var hand_hold_spot = player.hand.find_child("HoldSpot")
	reparent(player.hand)
	player.carried_weapon = self
	freeze = true
	transform = hand_hold_spot.transform
	rotation = 0.0
	interact_area.monitoring = false
	print(weapon_type)
	
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
		interact_area.monitoring = true
	pass # Replace with function body.
