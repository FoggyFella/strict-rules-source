extends Control

var can_move_mouse = false
@onready var mouse_def_pose = $Blastin.get_global_mouse_position()

func _ready():
	Global.should_play_input_sound = true
	randomize()
	$"THIS HAS TO BE ON TOP OF EVERYTHING".show()
	$BlacKScreen.show()
	if !Global.saw_os_intro:
		$AnimationTree.play("Intro")
	else:
		can_move_mouse = true
		$BlacKScreen.mouse_filter = MOUSE_FILTER_IGNORE
		$BlacKScreen.hide()

func _input(event):
	if event is InputEventMouseMotion and !can_move_mouse:
		warp_mouse(mouse_def_pose)

func enable_mouse():
	$BlacKScreen.mouse_filter = MOUSE_FILTER_IGNORE
	Global.saw_os_intro = true
	can_move_mouse = true

func _on_real_play_button_pressed():
	if $Screens/BlastinTerms/VBoxContainer/HBoxContainer/CheckBox.button_pressed:
		$Screens/BlastinTerms/VBoxContainer/HBoxContainer/CheckBox.disabled = true
		$Screens/BlastinTerms/VBoxContainer/RealPlayButton.disabled = true
		$AnimationTree.play("GameTransition")
		await(get_tree().create_timer(6.1).timeout)
		get_tree().change_scene_to_file("res://Scenes/HonorWarrior/SnowLands.tscn")
