extends Node

signal passed_room
signal entered_room

var player = null

var current_room = 0
var enemies_killed = 0

var camera_on = false
var should_play_input_sound = true
var disk_collected = false
var saw_the_mine_intro = true

var player_checkpoint_pos = Vector3.ZERO
var doors_info = {}

func _ready():
	randomize()

func _process(delta):
	if should_play_input_sound:
		if Input.is_action_just_pressed("shoot"):
			$mouse.pitch_scale = randf_range(0.95,1.05)
			$mouse.play()
func _input(event):
	if event is InputEventKey and not event.is_echo() and event.is_pressed():
		if should_play_input_sound:
			var sound = get_node("key"+str(randi_range(1,2)))
			sound.pitch_scale = randf_range(0.95,1.05)
			sound.play()
