extends CharacterBody3D

var direction_to_player = Vector2()
var speed = 5
var damage = 10

var color = Color(1,1,1)
var mix_amt = 0.0

var should_follow = true
var sleeping = false

func _ready():
	$Sprite3D.material_override.set("shader_parameter/modulate",color)
	$Sprite3D.material_override.set("shader_parameter/mix_amount",mix_amt)
	if color != Color(1,1,1):
		$OmniLight3D.light_color = color

func _physics_process(delta):
	if !sleeping:
		if should_follow:
			direction_to_player = global_position.direction_to(Global.player.global_position)
		velocity = direction_to_player * speed
		move_and_slide()
		var collission_count = get_slide_collision_count()
		for index in collission_count:
			var colission = get_slide_collision(index)
			if colission.get_collider().name == "Player":
				colission.get_collider().take_damage(damage)
				queue_free()
			else:
				$Sprite3D.hide()
				$AudioStreamPlayer.stop()
				$OmniLight3D.hide()
				sleeping = true
				$GPUParticles3D.emitting = true
				$removal.start()
			#queue_free()

func _on_removal_timeout():
	queue_free()

func _on_follow_timer_timeout():
	should_follow = false
