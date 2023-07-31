extends StaticBody2D

@onready var world = get_tree().current_scene
@export var health:int = 1

func take_damage():
	$hit.pitch_scale = randf_range(0.9,1.1)
	$hit.play()
	health -= 1
	
	if health <= 0:
		$Sprite2D.hide()
		$CollisionShape2D.disabled = true
		$over.pitch_scale = randf_range(0.9,1.1)
		$over.play()
		await($over.finished)
		queue_free()
		world.bricks_count -= 1
