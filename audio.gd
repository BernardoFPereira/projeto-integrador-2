# Code adapted from KidsCanCode
extends Node

var num_players = 24
var bus = "Sub1"

var available = []  # The available players.
var queue = []  # The queue of sounds to play.

var volume := -10

func _ready():
	for i in num_players:
		var p = AudioStreamPlayer2D.new()
		add_child(p)

		available.append(p)

		p.volume_db = -10
		p.finished.connect(_on_stream_finished.bind(p))
		p.bus = bus

func _on_stream_finished(stream):
	available.append(stream)

func play(sound_path, v):  # Path (or multiple, separated by commas)
	var sounds = sound_path.split(",")
	volume = v
	queue.append(sounds[randi() % sounds.size()].strip_edges())

func _process(_delta):
	if not queue.is_empty() and not available.is_empty():
		available[0].volume_db = volume
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available[0].pitch_scale = randf_range(0.9, 1.1)

		available.pop_front()
