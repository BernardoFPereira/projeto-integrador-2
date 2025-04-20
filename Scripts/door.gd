extends StaticBody2D

#@export var animation_player: AnimationPlayer
@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D

@onready var collision: CollisionShape2D = $Collision
#@onready var line_2d: Line2D = $Line2D

enum DoorState { OPEN, CLOSED }

var state := DoorState.CLOSED
var enemy_near := false
var enemy: Enemy

func _process(delta: float) -> void:
	if enemy_near:
		if enemy.state in [enemy.States.SEARCH, enemy.States.GOING_UP, enemy.States.GOING_DOWN]:
			if state == DoorState.CLOSED:
				open_door()
			else:
				return

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

#func _on_interact_area_body_entered(body: Node2D) -> void:
	#if (body.is_in_group("Player") or body.is_in_group("Enemy")) and state == DoorState.OPEN:
		#collision.disabled = true
		##line_2d.visible = true
		#PlayerManager.can_interact = true
		#PlayerManager.interact_target = self
	#
	#if body.is_in_group("Enemy"):
		#enemy_near = true
		#enemy = body


#func _on_interact_area_body_exited(body: Node2D) -> void:
	#if (body.is_in_group("Player") or body.is_in_group("Enemy")) and state == DoorState.OPEN:
		#collision.disabled = false
		##line_2d.visible = false
		#if PlayerManager.interact_target == self:
			#PlayerManager.can_interact = false
			#PlayerManager.interact_target = null
			#
	#if body.is_in_group("Enemy"):
		#enemy_near = false
		#enemy = null

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"opening":
			animation_player.play("open")
		"closing":
			animation_player.play("closed")
		_:
			pass

func _on_animated_sprite_2d_frame_changed() -> void:
	var occluder = $LightOccluder2D
	
	if animation_player.animation == "opening":
		if animation_player.frame == 1:
			occluder.visible = !occluder.visible
	if animation_player.animation == "closing":
		if animation_player.frame == 2:
			occluder.visible = !occluder.visible
