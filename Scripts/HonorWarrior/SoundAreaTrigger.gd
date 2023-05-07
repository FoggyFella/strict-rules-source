extends Area3D

@export var path_to_sound:NodePath
@onready var the_sound = get_node(path_to_sound)

func _on_body_entered(body):
	if body.name == "Player":
		if !the_sound.playing:
			the_sound.play()
			await the_sound.finished
			queue_free()
