extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer = $Timer
	timer.start()
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.
