extends Panel

var songs_data = [
	["Like the wind",preload("res://Assets/SFX/VoiceLines/Player/OS/music/like the wind.ogg")],
	["Sneaky Snitch",preload("res://Assets/SFX/VoiceLines/Player/OS/music/Sneaky Snitch.ogg")],
	["CIA",preload("res://Assets/SFX/VoiceLines/Player/OS/music/CIA.ogg")],
	]

@onready var song = $song
@onready var currently_playing = $"Currently playing"


var current_song = 1

func _ready():
	currently_playing.text = "Currently playing:\n None"
	song.stream = songs_data[0][1]
	song.play()
	song.stream_paused = true
	$Buttons/pause.text = "Play"

func _on_previous_pressed():
	current_song -= 1
	if current_song in range(1,songs_data.size()):# and current_song < 0:
		song.stream = songs_data[abs(current_song-1)][1]
	else:
		current_song = 3
		song.stream = songs_data[current_song-1][1]
	currently_playing.text = "Currently playing:\n" + songs_data[abs(current_song-1)][0]
	$Buttons/pause.text = "Pause"
	$AnimationPlayer.play("Spin")
	song.play()


func _on_pause_pressed():
	if !song.stream_paused:
		song.stream_paused = true
		$Buttons/pause.text = "Play"
		$AnimationPlayer.stop(false)
	else:
		song.stream_paused = false
		currently_playing.text = "Currently playing:\n" + songs_data[abs(current_song-1)][0]
		$Buttons/pause.text = "Pause"
		$AnimationPlayer.play("Spin")


func _on_next_pressed():
	current_song += 1
	if current_song <= songs_data.size():
		song.stream = songs_data[abs(current_song-1)][1]
	else:
		current_song = 1
		song.stream = songs_data[0][1]
	currently_playing.text = "Currently playing:\n" + songs_data[abs(current_song-1)][0]
	$Buttons/pause.text = "Pause"
	$AnimationPlayer.play("Spin")
	song.play()
