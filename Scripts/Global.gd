extends Node

## SIGNALS ##
signal passed_room
signal entered_room
signal settings_changed

## GLOBAL STATS FOR SOMETHING IDK ##
var player = null
var current_room = 0
var enemies_killed = 0

## THINGS THAT CHANGE THROUGH THE GAME ##

# DEFAULT IS TRUE #
var should_play_input_sound = true
var feed_active = true
var force_into_ex_fullscreen = true
# DEFAULT IS FALSE #
var camera_on = false
var turned_camera_off = false
var disk_collected = false
var saw_the_mine_intro = false
var saw_chase_intro = false
var saw_os_intro = false
var saw_boss_intro = false
var saw_corrupted_intro = false
var saw_snowlands_intro = false
var saw_coin_flip = false

var did_win = false

## SAVE STUFF ##
var player_checkpoint_pos = Vector3.ZERO
var doors_info = {}

## SETTINGS ##

var pixelization = 4
var sensitivity = 0.004

var im_debugging_shit = false

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
