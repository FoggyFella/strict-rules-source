extends Node3D

@onready var world = get_tree().current_scene

var laser = preload("res://Scenes/HonorWarrior/BossLaser.tscn")
var bullet = preload("res://Scenes/HonorWarrior/BossBullets.tscn")
var blood = preload("res://Scenes/HonorWarrior/EnemyBlood.tscn")

var damage = 10
var health = 3500

var previous_rotation = null
var player = null

var can_be_damaged = false
var dead = false
var should_rotate = false

enum States {
	NULL,
	IDLE,
	SHOOTING,
	LASER,
	PURPLE_SHOOTING
}
var current_state = States.NULL

var amount_of_attacks = 0

func _ready():
	randomize()

func _physics_process(delta):
	if should_rotate:
		var direction_to_player = global_position.direction_to(player.global_position)
		if can_be_damaged:
			match_rotation()
		rotation.y = lerp_angle(rotation.y, atan2(-direction_to_player.x, -direction_to_player.z), delta * 2.0)
	
func change_state(next_state):
	current_state = next_state
	match_state()

func match_state():
	match current_state:
		States.NULL:
			can_be_damaged = false
			open_eye()
			should_rotate = false
		States.IDLE:
			can_be_damaged = true
			should_rotate = true
			if $BeforeAttacks.is_stopped():
				randomize()
				$BeforeAttacks.start(randf_range(5,6))
		States.SHOOTING:
			should_rotate = true
			can_be_damaged = false
			open_eye()
			#shoot_purple(3)
			shoot(randi_range(2,3))
			amount_of_attacks += 1
		States.LASER:
			should_rotate = false
			can_be_damaged = false
			open_eye()
			amount_of_attacks += 1
			world.put_up_pillars()
			await(get_tree().create_timer(1.0,false).timeout)
			laser_attack(randi_range(2,3))
		States.PURPLE_SHOOTING:
			should_rotate = true
			can_be_damaged = false
			open_eye()
			shoot_purple(randi_range(2,3))
			amount_of_attacks += 1

func match_rotation():
	var the_rotation = rotation.y
	if previous_rotation == null:
		previous_rotation = the_rotation
	var test = abs(previous_rotation-the_rotation)
	#HEY IF IT DOESN'T WORK TRY CHANGING 0.005 to some other numer
	if test < 0.005:
		rotation_degrees.z = lerp(rotation_degrees.z,0.0,0.1)
		$Front.frame = 0
	else:
		var the_thing = previous_rotation-the_rotation
		if the_thing < 0.0:
			rotation_degrees.z = lerp(rotation_degrees.z,5.0,0.1)
			$Front.frame = 2
		else:
			rotation_degrees.z = lerp(rotation_degrees.z,-5.0,0.1)
			$Front.frame = 1
	previous_rotation = the_rotation

func shoot(amount):
	for i in range(amount):
		var bullet_inst = bullet.instantiate()
		bullet_inst.damage = damage
		bullet_inst.direction_to_player = self.global_position.direction_to(player.global_position)
		$fired.pitch_scale = randf_range(0.95,1.05)
		$fired.play()
		get_tree().current_scene.add_child(bullet_inst)
		bullet_inst.global_position = self.global_position
		await(get_tree().create_timer(0.7,false).timeout)
	change_state(States.IDLE)

func shoot_purple(amount):
	for i in range(amount):
		var bullet_inst = bullet.instantiate()
		bullet_inst.damage = 15
		bullet_inst.speed = 7
		bullet_inst.color = Color("85117a")
		bullet_inst.mix_amt = 0.6
		bullet_inst.direction_to_player = self.global_position.direction_to(player.global_position)
		$fired.pitch_scale = randf_range(0.95,1.05)
		$fired.play()
		get_tree().current_scene.add_child(bullet_inst)
		bullet_inst.global_position = self.global_position
		await(get_tree().create_timer(1.0,false).timeout)
	change_state(States.IDLE)

func laser_attack(amount_of_spins):
	var laser_inst = laser.instantiate()
	#laser_inst.scale = Vector3(2,1,2)
	laser_inst.rotation = Vector3(deg_to_rad(90),0.0,0.0)
	laser_inst.position = Vector3(0.0,0.0,0.03)
	$Front.add_child(laser_inst)
	await(get_tree().create_timer(2.5,false).timeout)
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self,"rotation",self.rotation + Vector3(0.0,deg_to_rad(360.0*amount_of_spins),0),2.5*amount_of_spins)
	await tween.finished
	can_be_damaged = true
	laser_inst.fade_out()
	await(get_tree().create_timer(2.0,false).timeout)
	world.put_down_pillars()
	change_state(States.IDLE)

func take_damage(amount,hit_point=self.global_positon):
	if can_be_damaged:
		can_be_damaged = false
		health -= amount
		$Front.frame = 3
		instance_blood()
		$HurtTimer.start(randf_range(0.9,1.5))
		if health <= 0:
			print("lole i'm dead")
			dead = true
			$CollisionShape3D.disabled = true
			die()


func instance_blood():
	var blood_inst = blood.instantiate()
	add_child(blood_inst)
	blood_inst.global_position = global_position
	blood_inst.look_at(player.global_position)
	blood_inst.emitting = true

func _on_hurt_timer_timeout():
	can_be_damaged = true
	$Front.frame = 0
	$Front.modulate += Color(0.05,-0.01,-0.01,0)

func open_eye():
	$Front.frame = 0
	$HurtTimer.stop()

func set_player(p):
	player = p

func turn_on_idle():
	change_state(States.IDLE)


func _on_before_attacks_timeout():
	randomize()
	if amount_of_attacks < 3:
		change_state(States.SHOOTING)
	elif amount_of_attacks == 3:
		change_state(States.LASER)
	elif amount_of_attacks > 3:
		var attack = randi_range(1,3)
		match attack:
			1:
				change_state(States.SHOOTING)
			2:
				change_state(States.LASER)
			3:
				change_state(States.PURPLE_SHOOTING)

func die():
	change_state(States.NULL)
	$BeforeAttacks.stop()
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self,"rotation",Vector3(deg_to_rad(16),self.rotation.y,self.rotation.z),0.5)
	$death.play()
	await(get_tree().create_timer(1.0,false).timeout)
	$Sprite3D.show()
	world.stop_boss_music()
	$Front.hide()
	$explosion.play()
	$DeathParticles.emitting = true
	var tween2 = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween2.tween_interval(1.0)
	tween2.tween_property($Sprite3D,"modulate",Color(1,1,1,0),2.0)
	await(get_tree().create_timer(4.5,false).timeout)
	get_tree().current_scene.dead_enemies += 1
	queue_free()
