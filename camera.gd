extends Camera2D

@export var target: Node2D

#@onready var glitch_fx: ColorRect = $CanvasLayer/GlitchFX
#@onready var noise_fx: ColorRect = $CanvasLayer/NoiseFX
@onready var screen_fx: CanvasLayer = $ScreenFX

func _physics_process(delta: float) -> void:
	#global_position.x = lerp(global_position.x, target.global_position.x, delta).round()
	global_position = global_position.lerp(target.global_position, (delta * 6))
	
	if !PlayerManager.is_in_shadow:
		screen_fx.visible = true
		#noise_fx.visible = true
	else:
		screen_fx.visible = false
		#noise_fx.visible = false
