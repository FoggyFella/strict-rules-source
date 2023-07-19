extends RayCast3D

var number = 2.0

@onready var middle = $Middle
@onready var left = $Left
@onready var right = $Right

@onready var right_cast = $RightCast
@onready var left_cast = $LeftCast
var casting = false

var lasers_colliding = 0
var should_player_take_damage = false

func _ready():
	$EndParticles.emitting = false
	middle.get_node("Hurtbox").body_entered.connect(on_hurtbox_body_entered)
	middle.get_node("Hurtbox").body_exited.connect(on_hurtbox_body_exited)
	
	left.get_node("Hurtbox").body_entered.connect(on_hurtbox_body_entered)
	left.get_node("Hurtbox").body_exited.connect(on_hurtbox_body_exited)
	
	right.get_node("Hurtbox").body_entered.connect(on_hurtbox_body_entered)
	right.get_node("Hurtbox").body_exited.connect(on_hurtbox_body_exited)
	
	scale = Vector3(0.01,1,0.01)
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self,"scale",Vector3(2,1,2),2.0)
	await(get_tree().create_timer(2.3,false).timeout)
	$Intro.play()
	$EndParticles.emitting = true
	casting = true
	$EndParticles/Laser.play()

func _physics_process(delta):
	if casting:
		if self.is_colliding():
			var col_point = to_local(get_collision_point())
			middle.scale.y = col_point.y/number
		else:
			middle.scale.y = target_position.y/number
			
		if right_cast.is_colliding():
			var col_point = to_local(right_cast.get_collision_point())
			$EndParticles.position.y = col_point.y
			right.scale.y = col_point.y/number
		else:
			right.scale.y = right_cast.target_position.y/number
		
		if left_cast.is_colliding():
			var col_point = to_local(left_cast.get_collision_point())
			left.scale.y = col_point.y/number
		else:
			left.scale.y = left_cast.target_position.y/number


func on_hurtbox_body_entered(body):
	lasers_colliding += 1
	if lasers_colliding == 3 and !should_player_take_damage:
		should_player_take_damage = true
		Global.player.take_damage(15)
		$HurtTimer.start()

func on_hurtbox_body_exited(body):
	lasers_colliding -= 1
	if lasers_colliding == 0:
		$HurtTimer.stop()
		should_player_take_damage = false

func _on_hurt_timer_timeout():
	Global.player.take_damage(5)

func fade_out():
	$EndParticles/Laser.stop()
	$EndParticles.emitting = false
	casting = false
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self,"scale",Vector3(0.01,1,0.01),2.0)
	await(tween.finished)
	queue_free()
