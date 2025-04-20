extends AnimatedSprite2D

func _ready() -> void:
	var spatter_to_spawn = randi_range(1, 3)
	var animation_to_play = "spatter%".format([spatter_to_spawn], "%")
	
	if randi_range(0,1) < 1:
		flip_h = true
	
	play(animation_to_play)
