extends Node

signal scene_changed

func change_scene(new_scene_path: String):
	var current_scene = get_tree().current_scene
	current_scene.queue_free()
	var new_scene = load(new_scene_path).instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	await emit_signal("scene_changed")
