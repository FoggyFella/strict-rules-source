extends Area3D

@export var path_to_enemies : NodePath
@onready var enemies = get_node(path_to_enemies)

func _on_body_entered(body):
	var room_number = int(str(enemies.name))
	if body.name == "Player" and !enemies.get_children().is_empty():
		for enemy in enemies.get_children():
			enemy.set_player(body)
		get_tree().current_scene.amount_of_enemies = enemies.get_child_count()
		Global.emit_signal("entered_room",room_number)
		Global.current_room = room_number
		queue_free()
