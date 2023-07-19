extends Area3D

@onready var world = get_tree().current_scene

func _on_body_entered(body):
	Global.disk_collected = true
	Global.player.switch_to_disk()
	world.open_all_doors()
	world.put_up_post_boss_fight_triggers()
	queue_free()
