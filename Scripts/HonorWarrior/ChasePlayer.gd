extends CharacterBody3D


@onready var head = $Head
@onready var camera_3d = $Head/Camera3d
@onready var animation_player = $AnimationPlayer
@onready var hud = $HUD
@onready var hand_left = $HUD/Control/HandLeft
@onready var hand_right = $HUD/Control/HandRight

@export var speed = 15.0
@export var lerp_weight = 0.2

var max_speed = 0.0
var destination = 0.0
var active = false

func _ready():
	hud.hide()
	max_speed = speed
	get_tree().current_scene.create_camera_pixelization($Head/Camera3d)
	$MeshInstance3d.hide()
	#await(get_tree().create_timer(0.3).timeout)
	#activate()

func _physics_process(delta):
	if !active:
		return
	if Input.is_action_just_pressed("move_left"):
		speed = 0.0
		destination += deg_to_rad(90)
		#$Music.pitch_scale = 0.9
		head.rotation.z = deg_to_rad(15)
		hand_left.skew = deg_to_rad(-28.0)
		hand_right.skew = deg_to_rad(-28.0)

		#head.rotation.y += deg_to_rad(90)
	if Input.is_action_just_pressed("move_right"):
		speed = 0.0
		#$Music.pitch_scale = 0.9
		destination += deg_to_rad(-90)
		head.rotation.z = deg_to_rad(-15)
		hand_left.skew = deg_to_rad(28.0)
		hand_right.skew = deg_to_rad(28.0)

		#head.rotation.y += deg_to_rad(-90)
	speed = lerp(speed,max_speed,0.1)
	head.rotation.y = lerp(head.rotation.y,destination,lerp_weight)
	head.rotation.z = lerp(head.rotation.z,0.0,lerp_weight)
	#$Music.pitch_scale = lerp($Music.pitch_scale,1.0,0.01)
	hand_left.skew = lerp(hand_left.skew,0.0,0.03)
	hand_right.skew = lerp(hand_right.skew,0.0,0.03)

	velocity = Vector3(0.0,velocity.y,-speed).rotated(Vector3.UP,head.global_rotation.y)
	#velocity.y -= 20.0*delta
	move_and_slide()
	
	if $Head/WallDetection.is_colliding() or !$FloorDetection.is_colliding():
		$Head/WallDetection.enabled = false
		$FloorDetection.enabled = false
		get_tree().current_scene.player_died()

func activate():
	if active == false:
		print("activating")
		active = true
		Global.player.turn_off_camera()
		animation_player.play("HandsAnimation")
		hud.show()
		camera_3d.make_current()
	else:
		print("deactivating")
		active = false
		Global.player.turn_on_camera()
		animation_player.stop()
		hud.hide()

func disable_hud():
	hud.hide()

func play_sfx():
	randomize()
	$RockStep.pitch_scale = randf_range(0.9,1.1)
	$RockStep.play()

func start_thing():
	active = false
	speed = 0.0
	await get_tree().create_timer(0.05).timeout
	active = true

func enable_particles():
	$Particles.emitting = true

func disable_particles():
	$Particles.emitting = false
