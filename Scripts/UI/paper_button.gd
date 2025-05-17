extends TextureButton

@onready var label: Label = $Label
@onready var position_marker: Marker2D = $Marker2D

var original_label_position: Vector2

func _ready() -> void:
	original_label_position = label.global_position

func _on_focus_entered() -> void:
	label.global_position = position_marker.global_position

func _on_pressed() -> void:
	label.global_position = position_marker.global_position
	#release_focus()

func _on_mouse_exited() -> void:
	label.global_position = original_label_position
	release_focus()

#func _on_try_again_mouse_exited() -> void:
	#label.global_position = original_label_position
	#release_focus()

#func _on_main_menu_mouse_exited() -> void:
	#label.global_position = original_label_position
	#release_focus()
