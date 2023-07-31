extends RigidBody2D

@onready var world = get_tree().current_scene

func _physics_process(delta):
	
	if world.bricks_count == 0:
		get_tree().reload_current_scene()
	
	if position.y > get_viewport_rect().end.y:
		get_tree().current_scene.ball_count = 0
		world.life_lost()
		queue_free()
	
	var bodies = get_colliding_bodies()

	for body in bodies:
		$AudioStreamPlayer2D.play()
		if body.is_in_group("bricks_group"):
			body.take_damage()
		if body.name == "Paddle":
			linear_velocity = Vector2(linear_velocity.x,-1150)
