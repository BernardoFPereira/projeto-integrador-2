extends StaticBody2D

#@export var animated_sprite: AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var collision: CollisionShape2D = $Collision
@onready var interact_highlight: Line2D = $InteractHighlight
@onready var animation_highlight: AnimationPlayer = $InteractHighlight/AnimationPlayer

enum DoorState { OPEN, CLOSED }

var state := DoorState.CLOSED
var enemy_near := false
var enemy: Enemy

func _process(delta: float) -> void:
	if PlayerManager.interact_target == self and PlayerManager.can_interact:
		if animated_sprite.is_playing():
			interact_highlight.visible = false
		else:
			interact_highlight.visible = true
	else:
		interact_highlight.visible = false
	
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
	Audio.play("res://Audio/FX/doorOpen_1.ogg", -15)
	state = DoorState.OPEN
	animation_highlight.play("open")
	animated_sprite.play("opening")
	collision.disabled = true

func close_door():
	Audio.play("res://Audio/FX/doorClose_4.ogg", -15)
	state = DoorState.CLOSED
	animated_sprite.play("closing")
	animation_highlight.play("closed")
	collision.disabled = false

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		enemy_near = true
		enemy = body

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		enemy_near = false
		enemy = null

func _on_animated_sprite_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"open":
			animated_sprite.stop()
		"closed":
			animated_sprite.stop()
		"opening":
			#animated_sprite.stop()
			animated_sprite.play("open")
		"closing":
			#animated_sprite.stop()
			animated_sprite.play("closed")
			
		_:
			pass

func _on_animated_sprite_2d_frame_changed() -> void:
	var occluder = $LightOccluder2D
	
	if animated_sprite.animation == "opening":
		if animated_sprite.frame == 1:
			occluder.visible = !occluder.visible
	if animated_sprite.animation == "closing":
		if animated_sprite.frame == 2:
			occluder.visible = !occluder.visible
