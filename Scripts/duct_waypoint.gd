extends Marker2D
class_name VentWaypoint

@export var way_left: Marker2D
@export var way_right: Marker2D
@export var way_up: Marker2D
@export var way_down: Marker2D

@export var is_exit: bool

var way_left_pos:= Vector2.ZERO
var way_right_pos:= Vector2.ZERO
var way_up_pos:= Vector2.ZERO
var way_down_pos:= Vector2.ZERO

#func _ready() -> void:
	#way_left_pos = way_left.global_position
	#way_right_pos = way_right.global_position
	#way_up_pos = way_up.global_position
	#way_down_pos = way_down.global_position
