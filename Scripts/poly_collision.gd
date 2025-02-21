extends StaticBody2D

var polygon: Polygon2D
var collision: CollisionPolygon2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	polygon = find_child("Polygon2D")
	collision = find_child("CollisionPolygon2D")
	
	collision.polygon = polygon.polygon
