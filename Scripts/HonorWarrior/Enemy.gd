extends CharacterBody3D

var bullet = preload("res://Scenes/HonorWarrior/EnemyBullet.tscn")
var blood = preload("res://Scenes/HonorWarrior/EnemyBlood.tscn")

@export var health: int = 100
@export var damage: int = 10
@export var bullet_damage: int = 15
@export var speed: float = 4
@export var foot_steps: String = "SnowStep"
@export var can_shoot: bool = false

@onready var sprite = $Sprite
@onready var ray_cast_3d = $RayCast3D

var gun_ready = false
var can_attack = true
var player = null
var dead = false

func _ready():
	randomize()
	sprite.modulate = Color(randf_range(0.1,1.0),randf_range(0.1,1.0),randf_range(0.1,1.0),1)
	if can_shoot:
		$Reload.start()
	
func set_player(p):
	await get_tree().create_timer(randf_range(0.0,0.8),false).timeout
	player = p
	if !dead:
		$Timer.start()
		sprite.play("Move")

func _physics_process(delta):
	if dead:
		return
	if player == null:
		return
	
	var vec_to_player = global_position.direction_to(player.global_position)
	ray_cast_3d.target_position = vec_to_player * 1.5
	velocity = vec_to_player.normalized() * speed
	move_and_slide()
	
	if ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider()
		if collider != null and collider.name == "Player":
			if can_attack:
				can_attack = false
				collider.take_damage(damage)
				$AttackTimeout.start()

func take_damage(amount,hit_point=self.global_positon):
	if player == null:
		return
	health -= amount
	instance_blood(hit_point)
	$damaged.pitch_scale = randf_range(0.7,0.9)
	$damaged.play()
	if health <= 0:
		dead = true
		$CollisionShape3D.disabled = true
		$Timer.stop()
		sprite.play("Die")
		get_tree().current_scene.dead_enemies += 1
		Global.enemies_killed += 1
		$death.pitch_scale = randf_range(0.7,0.9)
		$death.play()

func _on_attack_timeout_timeout():
	can_attack = true

func play_step_sound():
	if $Sprite.animation == "Move":
		get_node(foot_steps).pitch_scale = randf_range(0.8,1.2)
		get_node(foot_steps).play()


func _on_timer_timeout():
	play_step_sound()

func shoot():
	var bullet_inst = bullet.instantiate()
	bullet_inst.direction_to_player = $BulletSpawn.global_position.direction_to(player.global_position)
	bullet_inst.damage = bullet_damage
	$fired.pitch_scale = randf_range(0.95,1.05)
	$fired.play()
	get_tree().current_scene.add_child(bullet_inst)
	bullet_inst.global_position = $BulletSpawn.global_position


func _on_reload_timeout():
	if dead:
		return
	if player == null:
		$Reload.start(randf_range(3,5))
		return
	shoot()
	$Reload.start(randf_range(3,5))

func instance_blood(hit_point):
	var blood_inst = blood.instantiate()
	add_child(blood_inst)
	blood_inst.global_position = hit_point
	blood_inst.look_at(Global.player.global_position)
	blood_inst.emitting = true
