extends Node2D

@onready var interact_highlight: Line2D = $InteractHighlight

func interaction() -> void:
	PlayerManager.briefcase_found = true

func _on_interact_area_body_entered(body: Node2D) -> void:
	match body.get_class():
		"CharacterBody2D":
			interact_highlight.visible = true
			PlayerManager.can_interact = true
			PlayerManager.interact_target = self
		_:
			pass

func _on_interact_area_body_exited(body: Node2D) -> void:
	match body.get_class():
		"CharacterBody2D":
			interact_highlight.visible = false
			PlayerManager.can_interact = false
			PlayerManager.interact_target = null
		_:
			pass
