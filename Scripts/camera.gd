extends Camera2D

@export var target: Node2D

@onready var screen_fx: CanvasLayer = $"../ScreenFX"

func _physics_process(delta: float) -> void:
	global_position = global_position.lerp(target.global_position, (delta * 6))
	
	if !PlayerManager.is_in_shadow:
		screen_fx.visible = true
	else:
		screen_fx.visible = false
