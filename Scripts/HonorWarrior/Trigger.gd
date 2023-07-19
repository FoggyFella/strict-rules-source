extends Area3D

@export var path_to_enemies : NodePath
@onready var world = get_tree().current_scene
@onready var enemies = get_node(path_to_enemies)

func _on_body_entered(body):
	var room_number = int(str(enemies.name))
	if body.name == "Player" and !enemies.get_children().is_empty():
		for enemy in enemies.get_children():
			enemy.set_player(body)
		get_tree().current_scene.amount_of_enemies = enemies.get_child_count()
		Global.emit_signal("entered_room",room_number)
		Global.current_room = room_number
		if world.level_name == "Mines" and room_number == 7:
			if !Global.saw_boss_intro:
				world.get_node("AnimationPlayer").play("BossIntro")
			else:
				world.skip_boss_intro()
		queue_free()
