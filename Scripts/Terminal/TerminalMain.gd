extends Control

@export var interactible_thing:Area3D

var label_settings = preload("res://Scenes/Terminal/TerminalLabelSettings.tres")
@onready var label_template = $MainScreen/CommandBar/Label
@onready var input_bar = $MainScreen/CommandBar/InputBar

var in_start_sequence = false

var turned_on = false

var commands = {
	"test":"Yeah this command works",
	"help":"List of commands:\n
	start\n
	info\n
	help\n
	corsac\n
	version\n
	ping\n
	test",
	"scott":"oh hey you found a secret, Scott :>",
	"foggy":"is a bastard",
	"markiplier":"very sexy actually",
	"googie":"stupid idiot dog",
	"version":"Current version is 13.3.7",
	"ping":"Pinging corsac.com [228.12.42.07] with 32 bytes of data:\n
	Reply from 228.12.42.07: bytes=32 time=60ms TTL=105",
	"corsac":"Corsac Team are passionate team of game developers, bringing you unique game experiences.",
	"info":"This is a remote access terminal to Artificial Rules Controller(A.R.C.), to connect you need a disk with access keys",
	"manly":"awesome fella"
}

func boot_up():
	Global.player.can_pause = false
	turned_on = true
	$MainScreen/CommandBar/InputBar.clear()
	$AnimationPlayer.play("BootUp")

func _ready():
	#REMOVE BOOT UP IN THE FINAL
	#boot_up()
	pass
	
func _on_animation_player_animation_finished(anim_name):
	pass # Replace with function body.

func _on_input_bar_text_submitted(new_text):
	new_text = new_text.strip_edges(true,true).to_lower()
	$MainScreen/CommandBar/InputBar.clear()
	if !in_start_sequence:
		if new_text != "" and new_text != "start":
			if commands.has(new_text):
				add_label("> " + commands[new_text]+"
				")
			else:
				add_label("> Not recognized, type 'help' for list of commands
				")
		elif new_text == "start":
			if !Global.disk_collected:
				add_label("> Starting connection")
				add_label("> Disk with access keys not found, connection failed")
			else:
				$MainScreen/CommandBar/InputBar.release_focus()
				add_label("> Starting connection")
				add_label("> Disk with access keys found")
				await (get_tree().create_timer(1.5,false).timeout)
				in_start_sequence = true
				add_label("> Connected to A.R.C.")
				add_label("> Start A.R.C.? [Y/N]")
				$MainScreen/CommandBar/InputBar.grab_focus()
	else:
		if new_text == "y":
			interactible_thing.can_leave = false
			$MainScreen/CommandBar/InputBar.release_focus()
			add_label("> Initializing start sequence.")
			await (get_tree().create_timer(1.5,false).timeout)
			add_label("> Initializing start sequence..")
			await (get_tree().create_timer(1.5,false).timeout)
			add_label("> Initializing start sequence...")
			await (get_tree().create_timer(1.5,false).timeout)
			add_label("> A.R.C. activated")
			await (get_tree().create_timer(2.0,false).timeout)
			$MainScreen/CommandBar/InputBar.grab_focus()
			interactible_thing.force_out()
		elif new_text == "n":
			in_start_sequence = false
			add_label("> Disconnected")

func add_label(text):
	var new_label = label_template.duplicate()
	new_label.text = text
	$MainScreen/CommandBar.add_child(new_label)
	$MainScreen/CommandBar.move_child($MainScreen/CommandBar/InputBar,$MainScreen/CommandBar.get_child_count())

func clear_shit():
	for node in $MainScreen/CommandBar.get_children():
		if node.get_index() > 3 and node.name != "InputBar":
			node.queue_free()
	$MainScreen/CommandBar/InputBar.release_focus()
