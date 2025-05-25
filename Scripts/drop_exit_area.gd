extends Area2D

@onready var sprite_door_3: Door = $"../Doors/SpriteDoor3"

func _on_body_entered(body: Node2D) -> void:
	sprite_door_3.set_interactability(true)


#func _on_body_exited(body: Node2D) -> void:
	#sprite_door_3.interaction()
	#sprite_door_3.switch_interactability(false)
