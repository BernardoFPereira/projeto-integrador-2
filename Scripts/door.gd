extends StaticBody2D

@export var animation_player: AnimationPlayer

@onready var collision: CollisionShape2D = $Collision
@onready var line_2d: Line2D = $Line2D

enum DoorState { OPEN, CLOSED }

var state := DoorState.CLOSED

func interaction():
	match state:
		DoorState.OPEN:
			close_door()
		DoorState.CLOSED:
			open_door()

func open_door():
	state = DoorState.OPEN
	animation_player.play("opening")
	collision.disabled = true

func close_door():
	state = DoorState.CLOSED
	animation_player.play("closing")
	collision.disabled = false

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		#line_2d.visible = true
		PlayerManager.can_interact = true
		PlayerManager.interact_target = self

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		#line_2d.visible = false
		if PlayerManager.interact_target == self:
			PlayerManager.can_interact = false
			PlayerManager.interact_target = null

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"opening":
			animation_player.play("open")
		"closing":
			animation_player.play("closed")
		_:
			pass
