extends Node

# music
var music = load("res://Audio/Pause guitar.ogg")
var music_player: AudioStreamPlayer

# ambience
var ambience = load("res://Audio/gatve Varniu.ogg")
var ambience_player: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.stream = music
	music_player.bus = "Music"
	music_player.volume_db = 10
	self.add_child(music_player)
	music_player.play()
	
	ambience_player = AudioStreamPlayer.new()
	ambience_player.stream = ambience
	ambience_player.bus = "Music"
	ambience_player.volume_db = -20
	self.add_child(ambience_player)
	ambience_player.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(get_tree().current_scene.name)
	if get_tree().current_scene != null and get_tree().current_scene.name not in ["MainMenu", "OptionsMenu", "CreditsLevel"]:
		music_player.stop()
		ambience_player.stop()
		#print("in menus")
	elif get_tree().current_scene != null and get_tree().current_scene.name in ["MainMenu", "OptionsMenu", "CreditsLevel"]:
		if !music_player.playing and !ambience_player.playing:
			music_player.play()
			ambience_player.play()
		
	pass
