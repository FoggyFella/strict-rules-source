extends CharacterBody3D

var blood_spray = preload("res://Scenes/HonorWarrior/FaceBlood.tscn")
var bullet_decal = preload("res://Scenes/HonorWarrior/BulletDecal.tscn")

var health = 100
var max_health = 100
var damage = 100
var gravity = 20.0
var gun_rest_pos = Vector2(252,-255)
var _old_mouse = Vector2.ZERO

@export var eyes_texture:Texture
@export var level:String = "Snowlands"
@export var task:String = "KILL"
@export var speed : float = 5.0
@export var sensetivity : float = 0.004
@export var can_move = true
@export var can_rotate = true
@export var can_shoot = true
@export var step_sound = "SnowStep"
@export var starting_health : int = 100
@export var gun_sound: String = "Gun"
@export var should_glow_on_shot = false

@onready var blood_texture = $HUD/Control/BloodTexture
@onready var chat = $HUD/Chat
@onready var gun_sprite = $HUD/GunAnchor/GunSprite
@onready var animation_player = $AnimationPlayer
@onready var eyes = $HUD/GunAnchor/Outline/Eyes
@onready var animation_tree = $AnimationTree
@onready var ray_cast_3d = $Head/RayCast3D
@onready var head := $Head
@onready var camera = $Head/Camera3d
@onready var head_2 = $SubViewportContainer/SubViewport/Head2
@onready var camera_2 = $SubViewportContainer/SubViewport/Head2/Camera3d

func _ready():
	if Global.player_checkpoint_pos == Vector3.ZERO:
		if get_tree().current_scene.get_node_or_null("PlayerSpawn") != null:
			self.global_position = get_tree().current_scene.get_node("PlayerSpawn").global_position
	else:
		self.global_position = Global.player_checkpoint_pos
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	head_2.global_position = head.global_position
	head_2.rotation = head.rotation
	Global.player = self
	$HUD/Control/Panel/Stuff/Health/ProgressBar.max_value = max_health
	$HUD/Control/Panel/Stuff/Health/ProgressBar.value = health
	$HUD/Control/Panel/Stuff/Level/Label2.text = level
	$HUD/Control/Panel/Task/Label2.text = task
	eyes.texture = eyes_texture
	await get_tree().create_timer(0.1).timeout
	$Tv.queue_free()
	health = starting_health
	update_health()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("show_mouse"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			if can_rotate:
				head.rotate_y(-event.relative.x * sensetivity)
				head_2.rotate_y(-event.relative.x * sensetivity)
			if event.relative.x < 0:
				eyes.frame = 2
			else:
				eyes.frame = 1
			$Timer.start()
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	head_2.global_position = head.global_position
	head_2.rotation = head.global_rotation
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back") if can_move else Vector2.ZERO
	var direction = (head_2.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		animation_tree.set("parameters/Blend2/blend_amount",0.5)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		gun_sprite.position = gun_rest_pos
		animation_tree.set("parameters/Blend2/blend_amount",1.0)
	move_and_slide()
	if Input.is_action_just_pressed("shoot"):
		shoot()
	var collider = $Head/LookingRay.get_collider()
	if $Head/LookingRay.is_colliding():
		collider.on_entered(self)

func shoot():
	if !animation_player.is_playing() and can_shoot:
		camera_2.add_trauma(0.45)
		animation_player.play("shoot")
		get_node("SFX/"+gun_sound).pitch_scale = randf_range(0.9,1.1)
		get_node("SFX/"+gun_sound).play()
		var collission = ray_cast_3d.get_collider()
		if ray_cast_3d.is_colliding():
			if collission.has_method("take_damage"):
				collission.take_damage(damage)
			else:
				instance_bullet_hole(ray_cast_3d.get_collision_point(),ray_cast_3d.get_collision_normal())

func take_damage(amount):
	print("ouchie")
	health -= amount
	instance_blood()
	camera_2.add_trauma(0.7)
	update_health()
	$SFX/damage.pitch_scale = randf_range(0.75,0.9)
	$SFX/damage.play()
	if health <= 0:
		get_tree().current_scene.on_player_death()

func instance_blood(until_gone = 7):
	var blood_inst = blood_spray.instantiate()
	blood_inst.until_gone = until_gone
	get_node("HUD/GunAnchor/Outline/Face").add_child(blood_inst)
	blood_texture.modulate = Color(1,1,1,1)
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_interval(2)
	tween.tween_property(blood_texture,"modulate",Color(1,1,1,0),1)

func play_step_sound():
	if is_on_floor():
		get_node("SFX/"+step_sound).pitch_scale = randf_range(0.8,1.2)
		get_node("SFX/"+step_sound).play()

func _on_timer_timeout():
	eyes.frame = 0

func heal(amount):
	health += amount
	if health > max_health:
		health = max_health
	$SFX/heal.pitch_scale = randf_range(0.9,1.1)
	$SFX/heal.play()
	update_health()

func update_health():
	$HUD/Control/Panel/Stuff/Health/ProgressBar.value = health

func rotate_camera_to_default():
	head.rotation = Vector3.ZERO
	head_2.rotation = Vector3.ZERO

func disable_movement():
	can_rotate = !can_rotate
	can_move = !can_move
	can_shoot = !can_shoot

func glow_the_shot():
	if should_glow_on_shot:
		if $ShotLight.visible:
			$ShotLight.hide()
		else:
			$ShotLight.show()

func turn_off_sounds():
	Global.should_play_input_sound = false
	$HUD/TextureRect/Label2.text = "MICROPHONE AUDIO: ERROR"

func _on_until_delay_change_timeout():
	$HUD/TextureRect/Label3.text = "DELAY: " + str(randi_range(1,4)) + " sec"
	$UntilDelayChangeAgain.start(randf_range(1,2))

func _on_until_delay_change_again_timeout():
	$HUD/TextureRect/Label3.text = "DELAY: " + str(randi_range(1,4)) + " sec"
	$UntilDelayChange.start(randf_range(4,8))

func reset_checkpoint():
	Global.player_checkpoint_pos = Vector3.ZERO
	Global.doors_info.clear()

func saw_mine_intro():
	Global.saw_the_mine_intro = true

func change_task(new_task):
	$HUD/Control/Panel/Task/Label2.text = new_task

func hide_ui():
	if $HUD/Control/Panel.visible:
		$HUD/Control/Panel.hide()
		$HUD/GunAnchor.hide()
	else:
		$HUD/Control/Panel.show()
		$HUD/GunAnchor.show()

func cause_shake(amount):
	camera_2.add_trauma(amount)

func instance_bullet_hole(the_position,normal):
	var bul_inst = bullet_decal.instantiate()
	get_tree().current_scene.add_child(bul_inst)
	bul_inst.global_transform.origin = the_position
	bul_inst.look_at(the_position + normal,Vector3.UP)
