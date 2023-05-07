extends CharacterBody3D

var health = 100
var max_health = health

var damage = 100
var speed = 10
var mouse_sens = 0.5
var gravity = 20.0
var gun_rest_pos = Vector2(252,-255)
var my_velocity = Vector3.ZERO
var last_pos = Vector2.ZERO

@onready var gun_sprite = $HUD/GunAnchor/GunSprite
@onready var animation_player = $AnimationPlayer
@onready var animation_tree = $AnimationTree
@onready var ray_cast_3d = $RayCast3D
@onready var ground_cast = $GroundCast
@onready var head = $HUD/GunAnchor/Head
@onready var camera_3d = $Camera3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#await get_tree().process_frame
	#get_tree().call_group("enemies","set_player",self)

func _input(event):
	if event is InputEventMouseMotion:
		last_pos = head.get_global_mouse_position()
		if event.relative.x < 0:
			head.frame = 2
		else:
			head.frame = 1
		rotation_degrees.y -= mouse_sens * event.relative.x

func _physics_process(delta):
	var move_vec = Vector3()
	var is_actually_on_floor = ground_cast.is_colliding()
	if Input.is_action_pressed("move_forward"):
		move_vec.z -= 1
	if Input.is_action_pressed("move_back"):
		move_vec.z += 1
	if Input.is_action_pressed("move_left"):
		move_vec.x -= 1
	if Input.is_action_pressed("move_right"):
		move_vec.x += 1
	if move_vec == Vector3.ZERO:
		gun_sprite.position = gun_rest_pos
		animation_tree.set("parameters/Blend2/blend_amount",1.0)
	else:
		animation_tree.set("parameters/Blend2/blend_amount",0.5)
	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0,1,0),rotation.y)
	my_velocity = (move_vec * speed * delta)
	if !is_actually_on_floor:
		my_velocity.y -= gravity * delta
	move_and_collide(my_velocity)
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot():
	if !animation_player.is_playing():
		animation_player.play("shoot")
		var collission = ray_cast_3d.get_collider()
		if ray_cast_3d.is_colliding() and collission.has_method("take_damage"):
			collission.take_damage(damage)

func take_damage(amount):
	print("ouchie")
	health -= amount
	if health <= 0:
		get_tree().reload_current_scene()
