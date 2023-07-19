extends Area3D

@onready var world = get_tree().current_scene

func _on_body_entered(body):
	Global.player_checkpoint_pos = Vector3.ZERO
	Global.doors_info = {}
	world.change_to_corrupted()
	queue_free()
