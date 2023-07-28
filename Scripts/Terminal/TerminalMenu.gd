extends Control

var label_settings = preload("res://Scenes/Terminal/TerminalLabelSettings.tres")

@onready var label_template = $MainScreen/CommandBar/Label
@onready var input_bar = $MainScreen/CommandBar/InputBar
@onready var world = get_tree().current_scene

var commands = {
	"help":"List of commands:\n
	start\n
	settings\n
	exit\n",
}

var actual_commands = ["start","settings","exit","chase_skip"]

func boot_up():
	$MainScreen/blocker.hide()

func _on_animation_player_animation_finished(anim_name):
	pass # Replace with function body.

func _on_input_bar_text_submitted(new_text):
	new_text = new_text.strip_edges(true,true).to_lower()
	$MainScreen/CommandBar/InputBar.clear()
	if new_text != "" and !new_text in actual_commands:
		if commands.has(new_text):
			add_label("> " + commands[new_text]+"
			")
		else:
			add_label("> Not recognized, type 'help' for list of commands
			")
	elif new_text in actual_commands:
		if new_text == "start":
			add_label("> Starting game
			")
			world.on_start()
		elif new_text == "exit":
			add_label("> Exiting...
			")
			world.on_exit()
		elif new_text == "settings":
			add_label("> Entering settings
			")
			world.on_settings()
		elif new_text == "chase_skip":
			add_label("> Is this canon
			")
			world.chase_skip()

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
