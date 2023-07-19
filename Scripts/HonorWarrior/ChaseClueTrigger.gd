extends Area3D

@onready var world = get_tree().current_scene

@export var clue:String = "Forward"

func _on_body_entered(body):
	world.show_chase_message(clue)
	queue_free()
