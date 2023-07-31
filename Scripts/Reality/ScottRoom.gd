extends Node3D

var normal_env = preload("res://Assets/More Realistic Stuff/ScottRoomEnv.tres")
var good_env = preload("res://Assets/More Realistic Stuff/ScottRoomGood.tres")
var pc_on_mat = preload("res://Assets/More Realistic Stuff/pc_on.tres")

func _ready():
	Global.should_play_input_sound = false
	$UI/Credits.position = Vector2(241,655)
	$UI/SkipCredits.hide()
	#switch_to_good_env()


func _on_light_switch_finished():
	await(get_tree().create_timer(1.0).timeout)
	$RealityPlayer.can_move = true
	$DirectionalLight3D.show()
	$Props/Lamp/DirectionalLight3D2.hide()

func _on_light_switch_interacted():
	$RealityPlayer.can_move = false
	$DirectionalLight3D.hide()
	$Props/Lamp/DirectionalLight3D2.show()

func break_window():
	$WindowBreak.play()
	$Props/Glass2.hide()
	$Props/GlassShards.show()
	$Props/BrickText.position = Vector3(2.958,0.183,2.495)

func _on_bed_interacted():
	if !Global.did_win:
		$AnimationPlayer.play("BedSleep")
	else:
		$AnimationPlayer.play("BedSleepGood")

func teleport_player():
	$RealityPlayer.position = $BedWakeTeleport.position
	$RealityPlayer.rotation = $BedWakeTeleport.rotation

func _on_brick_interacted():
	$RealityPlayer.can_move = false
	$RealityPlayer.can_interact = false
	$AnimationPlayer.play("PickingUpBrick")

func bad_change():
	get_tree().change_scene_to_file("res://Scenes/Reality/BadEnding.tscn")

func switch_to_good_env():
	$DirectionalLight3D.hide()
	$GoodSun.show()
	$Ambience.stop()
	$MorningAmbience.play
	$Props/Pc/pcnoise.play()
	$WorldEnvironment.environment = good_env
	$Props/Pc.set_surface_override_material(3,pc_on_mat)
	$Props/Computer.interacted_already = true

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
