extends Node3D

func _ready():
	Global.should_play_input_sound = false


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
	$AnimationPlayer.play("BedSleep")

func teleport_player():
	$RealityPlayer.position = $BedWakeTeleport.position
	$RealityPlayer.rotation = $BedWakeTeleport.rotation

func _on_brick_interacted():
	$RealityPlayer.can_move = false
	$RealityPlayer.can_interact = false
	$AnimationPlayer.play("PickingUpBrick")

func bad_change():
	get_tree().change_scene_to_file("res://Scenes/Reality/BadEnding.tscn")
