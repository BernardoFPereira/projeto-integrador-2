extends Node2D

func _on_animation_finished() -> void:
	self.queue_free()
