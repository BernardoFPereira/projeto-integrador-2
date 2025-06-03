extends Node

signal scene_changed

func change_scene(new_scene_path: String):
	#var audio_nodes = get_tree().get_nodes_in_group("Audio")
	#for node: AudioStreamPlayer in audio_nodes:
		#node.stream_paused = true
		#node.reparent(get_tree().root)
	
	var current_scene = get_tree().current_scene
	current_scene.queue_free()
	var new_scene = load(new_scene_path).instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	
	#for node in audio_nodes:
		#node.reparent(new_scene)
		#node.stream_paused = false
		#
	await emit_signal("scene_changed")
