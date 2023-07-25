extends Node3D

func _ready():
	$UI/Credits.position = Vector2(241,655)
	$UI/SkipCredits.hide()

func show_credits():
	$UI/SkipCredits.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var tween = create_tween()
	tween.tween_property($UI/Credits,"position",Vector2(241,-1557.012),70.0)
	await(tween.finished)
	await(get_tree().create_timer(2.0).timeout)
	var fade_tween = create_tween()
	fade_tween.tween_property($UI/BlackBg,"color",Color("000000"),3.0)
	await(fade_tween.finished)
	await(get_tree().create_timer(1.0).timeout)
	get_tree().change_scene_to_file("res://Scenes/Reality/EndScreen.tscn")
	
func _on_skip_credits_pressed():
	get_tree().change_scene_to_file("res://Scenes/Reality/EndScreen.tscn")
