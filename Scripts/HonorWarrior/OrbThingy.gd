extends Area3D

@export var part_to_show:String = "none"

@onready var world = get_tree().current_scene

func _ready():
	show()

func _on_body_entered(body):
	queue_free()
	world.on_orb_collected()
	if part_to_show != "none":
		world.show_part(part_to_show)

func dissapear():
	$AnimationPlayer.play("Dissapear")
