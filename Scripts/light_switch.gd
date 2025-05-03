extends Node2D

@export var connected_lights: Array[Node2D]

@onready var interact_highlight: Line2D = $Line2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

enum States { ON, OFF }
@export_enum("WORKING", "BROKEN") var switch_condition = "WORKING"

var state: States

func _ready() -> void:
	match switch_condition:
		"WORKING":
			animated_sprite.sprite_frames = preload("res://Sprites/SpriteFrames/light_switch.tres")
		"BROKEN":
			animated_sprite.sprite_frames = preload("res://Sprites/SpriteFrames/broken_light_switch.tres")

func _process(delta: float) -> void:
	if PlayerManager.interact_target == self and PlayerManager.can_interact:
		interact_highlight.visible = true
	else:
		interact_highlight.visible = false
	
	match state:
		States.ON:
			animated_sprite.play("on")
		States.OFF:
			animated_sprite.play("off")

func set_state(new_state: States) -> void:
	if new_state != state:
		state = new_state

func interaction():
	Audio.play("res://Audio/FX/metalLatch.ogg", -10)
	match state:
		States.ON:
			pass
		States.OFF:
			if switch_condition != "BROKEN":
				Audio.play("res://Audio/FX/buzz.ogg", -10)
			pass
	
	match state:
		States.ON:
			set_state(States.OFF)
		States.OFF:
			set_state(States.ON)
	
	if switch_condition != "BROKEN":
		if connected_lights:
			for light in connected_lights:
				light.switch_power()

#func _on_interact_area_body_entered(body: Node2D) -> void:
	#if body.is_in_group("Player"):
		#PlayerManager.can_interact = true
		#line_2d.visible = true
		#PlayerManager.interact_target = self

#func _on_interact_area_body_exited(body: Node2D) -> void:
	#if body.is_in_group("Player"):
		#line_2d.visible = false
		#if PlayerManager.interact_target == self:
			#PlayerManager.can_interact = false
			#PlayerManager.interact_target = null
