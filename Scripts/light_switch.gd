extends Node2D

@export var connected_light: Light

@onready var line_2d: Line2D = $Line2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func interaction():
	#connected_light.enabled = !connected_light.enabled
	#connected_light.light_detect_area.monitoring = !connected_light.light_detect_area.monitoring
	connected_light.switch_power()

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		PlayerManager.can_interact = true
		line_2d.visible = true
		PlayerManager.interact_target = self

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		line_2d.visible = false
		if PlayerManager.interact_target == self:
			PlayerManager.can_interact = false
			PlayerManager.interact_target = null
