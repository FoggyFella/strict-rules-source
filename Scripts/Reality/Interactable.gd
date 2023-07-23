class_name Interactable
extends StaticBody3D

signal interacted

@export var voice_line_to_play:String = ""

var interacted_already = false

func interaction():
	emit_signal("interacted")
	interacted_already = true
	if voice_line_to_play != "":
		var voice_line = get_tree().current_scene.get_node("VoiceLines/"+voice_line_to_play)
		voice_line.play()
