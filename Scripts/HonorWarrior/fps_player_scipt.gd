extends CharacterBody3D

var blood_spray = preload("res://Scenes/HonorWarrior/FaceBlood.tscn")
var bullet_decal = preload("res://Scenes/HonorWarrior/BulletDecal.tscn")
var step = preload("res://Scenes/HonorWarrior/BloodStep.tscn")

var health = 100
var max_health = 100
var damage = 100
var gravity = 20.0
var gun_rest_pos = Vector2(252,-255)
var amount_of_steps = 0
var flip = false

var direction = Vector3()

@export var logo_texture:Texture
@export var eyes_texture:Texture
@export var level:String = "Snowlands"
@export var task:String = "KILL"
@export var speed : float = 5.0
@export var sensetivity : float = 0.004
@export var can_move = true
@export var should_leave_steps = false
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
@onready var bullet_ray = $Head/BulletRay
@onready var head := $Head
@onready var camera = $Head/Camera3d

var can_pause = true

var window_modes = [
	DisplayServer.WINDOW_MODE_FULLSCREEN,
	DisplayServer.WINDOW_MODE_WINDOWED,
	DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
]

var sfx_buses = [1,2,3,4,5]

var music_buses = [6,7]

func _ready():
	if Global.player_checkpoint_pos == Vector3.ZERO:
		if get_tree().current_scene.get_node_or_null("PlayerSpawn") != null:
			self.global_position = get_tree().current_scene.get_node("PlayerSpawn").global_position
	else:
		self.global_position = Global.player_checkpoint_pos
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.player = self
	$HUD/Control/Panel/Stuff/Health/ProgressBar.max_value = max_health
	$HUD/Control/Panel/Stuff/Health/ProgressBar.value = health
	$HUD/Control/Panel/Stuff/Level/Label2.text = level
	$HUD/Control/Panel/Task/Label2.text = task
	$HUD/Control/Panel/TextureRect.texture = logo_texture
	$Head/Camera3d/BossLaser.show()
	$HUD/PauseMenu.hide()
	$HUD/PauseMenu/Settings/SettingsContainer/Pixelation/PixelationBox.value = Global.pixelization
	eyes.texture = eyes_texture
	health = starting_health
	update_health()
	load_feed_status()
	$MeshInstance3d.hide()
	if !Global.should_play_input_sound:
		turn_off_sounds()
	set_correct_setting_values()
	await(get_tree().create_timer(0.3).timeout)
	$Head/Camera3d/BossLaser.queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("show_mouse"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			if can_rotate:
				head.rotate_y(-event.relative.x * Global.sensitivity)
			if event.relative.x < 0:
				eyes.frame = 2
			else:
				eyes.frame = 1
			$Timer.start()
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back") if can_move else Vector2.ZERO
	direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP,head.global_rotation.y).normalized()#(head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		animation_tree.set("parameters/Blend2/blend_amount",0.5)
		animation_tree.set("parameters/Blend2 2/blend_amount",0.4)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		gun_sprite.position = gun_rest_pos
		animation_tree.set("parameters/Blend2/blend_amount",1.0)
		animation_tree.set("parameters/Blend2 2/blend_amount",1.0)
	move_and_slide()
	
	if Input.is_action_just_pressed("shoot"):
		shoot()
		
	if Input.is_action_just_pressed("pause") and can_pause:
		enter_pause()
	
	var collider = $Head/LookingRay.get_collider()
	if $Head/LookingRay.is_colliding():
		collider.on_entered(self)
	
	if Input.is_action_just_pressed("restart") and Global.im_debugging_shit:
		get_tree().reload_current_scene()

func shoot():
	if !animation_player.is_playing() and can_shoot:
		camera.add_trauma(0.45)
		animation_player.play("shoot")
		get_node("SFX/"+gun_sound).pitch_scale = randf_range(0.9,1.1)
		get_node("SFX/"+gun_sound).play()
		var collission = bullet_ray.get_collider()
		if bullet_ray.is_colliding():
			if collission.has_method("take_damage"):
				collission.take_damage(damage,bullet_ray.get_collision_point())
			else:
				instance_bullet_hole(bullet_ray.get_collision_point(),bullet_ray.get_collision_normal())

func take_damage(amount):
	print("ouchie")
	health -= amount
	instance_blood()
	camera.add_trauma(0.7)
	update_health()
	$SFX/damage.pitch_scale = randf_range(0.75,0.9)
	$SFX/damage.play()
	if health <= 0:
		$SFX/low_hp.stop()
		get_tree().current_scene.on_player_death()
	elif health <= 40:
		$SFX/low_hp.play()

func instance_blood(until_gone = 7):
	var blood_inst = blood_spray.instantiate()
	blood_inst.until_gone = until_gone
	get_node("HUD/GunAnchor/Outline/Face").add_child(blood_inst)
	blood_texture.modulate = Color(1,1,1,1)
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_interval(2)
	tween.tween_property(blood_texture,"modulate",Color(1,1,1,0),1)

func instance_bullet_hole(the_position,normal):
	var bul_inst = bullet_decal.instantiate()
	get_tree().current_scene.add_child(bul_inst)
	bul_inst.global_transform.origin = the_position
	bul_inst.look_at(the_position + normal,Vector3.UP)
	bul_inst.global_rotation.z = randf_range(-6.28319,6.28319)

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
	if health > 40:
		$SFX/low_hp.stop()
	$SFX/heal.pitch_scale = randf_range(0.9,1.1)
	$SFX/heal.play()
	update_health()

func update_health():
	$HUD/Control/Panel/Stuff/Health/ProgressBar.value = health

func rotate_camera_to_default():
	head.rotation = Vector3.ZERO

func disable_movement():
	can_rotate = !can_rotate
	can_move = !can_move
	if !Global.disk_collected:
		can_shoot = !can_shoot

func glow_the_shot():
	if should_glow_on_shot:
		if $ShotLight.visible:
			$ShotLight.hide()
		else:
			$ShotLight.show()

func turn_off_sounds():
	Global.should_play_input_sound = false
	$HUD/FeedActiveEffect/Label2.text = "MICROPHONE AUDIO: ERROR"

func _on_until_delay_change_timeout():
	$HUD/FeedActiveEffect/Label3.text = "DELAY: " + str(randi_range(1,4)) + " sec"
	$UntilDelayChangeAgain.start(randf_range(1,2))

func _on_until_delay_change_again_timeout():
	$HUD/FeedActiveEffect/Label3.text = "DELAY: " + str(randi_range(1,4)) + " sec"
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
	camera.add_trauma(amount)

func give_blood_steps(amount):
	amount_of_steps += amount

func spawn_snow_steps():
	if should_leave_steps and is_on_floor():
		var step_inst = step.instantiate()
		step_inst.flip_h = flip
		flip = !flip
		get_tree().current_scene.add_child(step_inst)
		step_inst.global_position = $StepSpawn.global_position
		step_inst.global_rotation.y = head.global_rotation.y

func spawn_blood_steps():
	if amount_of_steps > 0 and is_on_floor():
		amount_of_steps -= 1
		var step_inst = step.instantiate()
		step_inst.flip_h = flip
		flip = !flip
		step_inst.modulate = Color("691313d7")
		get_tree().current_scene.add_child(step_inst)
		step_inst.global_position = $StepSpawn.global_position
		step_inst.global_rotation.y = head.global_rotation.y

func switch_to_disk():
	change_task("USE THE DISK")
	$HUD/Control/Panel/Stuff/Weapon/Label2.text = "DISK"
	can_shoot = false
	$HUD/Crosshair.hide()
	$AnimationTree.set("parameters/Transition/transition_request","has_disk")

func turn_off_camera():
	can_rotate = false
	can_shoot = false
	can_move = false
	camera.get_node("PixelEffect").hide()
	$HUD/Control/Panel.hide()
	$HUD/GunAnchor.hide()
	$HUD/Crosshair.hide()

func turn_on_camera():
	can_rotate = true
	can_move = true
	if !Global.disk_collected:
		can_shoot = true
	camera.get_node("PixelEffect").show()
	camera.make_current()
	$HUD/Control/Panel.show()
	$HUD/GunAnchor.show()
	$HUD/Crosshair.show()

func load_feed_status():
	if !Global.feed_active:
		$HUD/FeedActiveEffect.hide()
		$HUD/FeedNotActive.show()
	else:
		$HUD/FeedActiveEffect.show()
		$HUD/FeedNotActive.hide()

func turn_feed_off():
	Global.feed_active = false
	$SFX/feedturnoff.play()
	await(get_tree().create_timer(1.1,false).timeout)
	AudioServer.set_bus_volume_db(0,-80.0)
	$HUD/FeedActiveEffect/itsoff.show()
	can_move = false
	can_shoot = false
	can_rotate = false
	can_pause = false
	await(get_tree().create_timer(5.0,false).timeout)
	AudioServer.set_bus_volume_db(0,0.0)
	$HUD/FeedActiveEffect.hide()
	$HUD/FeedNotActive.show()
	can_move = true
	can_rotate = true
	can_pause = true

func enter_pause():
	get_tree().paused = true
	can_pause = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$HUD/PauseMenu/Buttoins/Resume.grab_focus()
	$HUD/PauseMenu.show()

func _on_resume_pressed():
	get_tree().paused = false
	can_pause = true
	$HUD/PauseMenu.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_settings_pressed():
	$HUD/PauseMenu/Buttoins.hide()
	$HUD/PauseMenu/Label.hide()
	$HUD/PauseMenu/Settings.show()

func change_pause(yeah:bool):
	can_pause = yeah

func _on_exit_pressed():
	get_tree().quit()

func _on_close_settings_pressed():
	$HUD/PauseMenu/Buttoins.show()
	$HUD/PauseMenu/Label.show()
	$HUD/PauseMenu/Settings.hide()
	
	Global.emit_signal("settings_changed")


func _on_window_options_item_selected(index):
	DisplayServer.window_set_mode(window_modes[index])


func _on_pixelation_box_value_changed(value):
	Global.pixelization = value


func set_correct_setting_values():
	$HUD/PauseMenu/Settings/SettingsContainer/Music/MusicSlider.value = AudioServer.get_bus_volume_db(6)
	$HUD/PauseMenu/Settings/SettingsContainer/Sfx/SfxSlider.value = AudioServer.get_bus_volume_db(1)
	$HUD/PauseMenu/Settings/SettingsContainer/Sensitity/SensSlider.value = Global.sensitivity
	$HUD/PauseMenu/Settings/SettingsContainer/Pixelation/PixelationBox.value  = Global.pixelization
	
	var window_mode = DisplayServer.window_get_mode()
	
	if window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		$HUD/PauseMenu/Settings/SettingsContainer/Window/WindowOptions.select(0)
	elif window_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		$HUD/PauseMenu/Settings/SettingsContainer/Window/WindowOptions.select(2)
	elif window_mode == DisplayServer.WINDOW_MODE_WINDOWED:
		$HUD/PauseMenu/Settings/SettingsContainer/Window/WindowOptions.select(1)
	
	
func _on_sfx_slider_value_changed(value):
	for sfx_bus in sfx_buses:
		if value > -30.0:
			AudioServer.set_bus_mute(sfx_bus,false)
			AudioServer.set_bus_volume_db(sfx_bus,value)
		else:
			AudioServer.set_bus_mute(sfx_bus,true)


func _on_music_slider_value_changed(value):
	for music_bus in music_buses:
		if value > -30.0:
			AudioServer.set_bus_mute(music_bus,false)
			AudioServer.set_bus_volume_db(music_bus,value)
		else:
			AudioServer.set_bus_mute(music_bus,true)

func show_choice():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$HUD/CoinChoice.show()

func _on_heads_pressed():
	$HUD/CoinChoice.hide()
	get_tree().current_scene.chosen_coin = "heads"
	get_tree().current_scene.coin_scene()

func _on_tails_pressed():
	$HUD/CoinChoice.hide()
	get_tree().current_scene.chosen_coin = "tails"
	get_tree().current_scene.coin_scene()

func _on_sens_slider_value_changed(value):
	Global.sensitivity = value

func allow_pause():
	can_pause = true

func disallow_pause():
	can_pause = false
