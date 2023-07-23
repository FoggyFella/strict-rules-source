extends Node3D

func _ready():
	$UI/Credits.position = Vector2(241,655)

func show_credits():
	var tween = create_tween()
	tween.tween_property($UI/Credits,"position",Vector2(241,-1557.012),70.0)
	await(tween.finished)
	await(get_tree().create_timer(2.0).timeout)
	var fade_tween = create_tween()
	fade_tween.tween_property($UI/BlackBg,"color",Color("000000"),3.0)
	await(fade_tween.finished)
	
