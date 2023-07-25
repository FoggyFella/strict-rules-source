extends Control

func _ready():
	if Global.did_win:
		$Shit/Label.text = "You got the good ending"
	else:
		$Shit/Label.text = "You got the bad ending"

func _on_no_pressed():
	get_tree().quit()

func _on_yes_pressed():
	Global.start_from_flip = true
	get_tree().change_scene_to_file("res://Scenes/HonorWarrior/Corrupted.tscn")
