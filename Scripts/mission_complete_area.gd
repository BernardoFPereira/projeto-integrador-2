extends Area2D

@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var main_script: Node = $".."

func _process(delta: float) -> void:
	if main_script.objective_complete and !audio_stream_player.playing:
		ring()
	
func ring():
	audio_stream_player.play()

func stop_ringing():
	audio_stream_player.stop()

func _on_body_entered(body: Node2D) -> void:
	stop_ringing()
