extends Node3D

func _ready():
	await get_tree().create_timer(0.1).timeout
	$Tv2.queue_free()
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		$AnimationPlayer.play("Camera")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Camera":
		$AnimationPlayer.play("CameraSway")
