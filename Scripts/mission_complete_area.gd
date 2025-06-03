extends Area2D

@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var main_script: Node = $".."

var player_reached := false

func _process(delta: float) -> void:
	if main_script.objective_complete and !audio_stream_player.playing and !player_reached:
		ring()

func ring():
	audio_stream_player.play()

func stop_ringing():
	audio_stream_player.stop()

func _on_body_entered(body: Node2D) -> void:
	player_reached = true
	stop_ringing()
