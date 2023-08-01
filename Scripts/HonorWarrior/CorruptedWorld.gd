extends Node3D

@onready var chase_player = $ChasePlayer
@onready var world_environment = $WorldEnvironment

var chat_message = preload("res://Scenes/HonorWarrior/ChatMessage.tscn")
var screen_message = preload("res://Scenes/HonorWarrior/ScreenMessage.tscn")
var pixel_effect = preload("res://Scenes/HonorWarrior/PixelEffect.tscn")

var times_fallen = 0
var amount_collected = 0
var purple_color = "7953cc"

var default_environment = null

var fog_enabled = false

@export var some_gridmap:String = "name"
@export var reset_some_gridmap:bool=false : set = set_start

@export var fog_move_speed = 0.05

var chosen_coin = ""

func set_start(val:bool):
	if some_gridmap != "name":
		var the_map = get_node(some_gridmap)
		the_map.clear()

func _ready():
	get_tree().paused = false
	Global.should_play_input_sound = false
	Global.feed_active = false
	Global.disk_collected = false
	if !Global.saw_corrupted_intro:
		$ScreenMessages/BlackBg.show()
		$AnimationPlayer.play("fade_out")
		Global.saw_corrupted_intro = true
	else:
		$ScreenMessages/BlackBg.hide()
	Global.player.load_feed_status()
	$SecretLabel.hide()
	$ScreenMessages/BlackBg.color = Color(0,0,0,1)
	create_camera_pixelization(get_node("Player").camera)
	if Global.saw_chase_intro:
		$Player.position = $PlayerRespawn.position
		$Part7.position = Vector3.ZERO
	disable_fog()
	
	if Global.im_debugging_shit:
		$Part7.global_position = Vector3(0,0,0)
		$ChaseDoors.global_position = Vector3(0,0,0)
	else:
		$Part7.global_position = Vector3(0,-30,0)
		$ChaseDoors.global_position = Vector3(0,-30,0)
	
	if Global.saw_chase_intro:
		$Part7.global_position = Vector3(0,0,0)
		$ChaseDoors.global_position = Vector3(0,0,0)
		
	if Global.start_from_flip:
		$AnimationPlayer.stop()
		$Part7.position = Vector3.ZERO
		$ChaseDoors.global_position = Vector3(0,0,0)
		$FinalSceneStuff/AreaFinal.queue_free()
		$Player.can_pause = false
		$ScreenMessages/BlackBg.hide()
		$ScreenMessages/BlackBg.modulate = Color(0,0,0,1.0)
		$Player.global_position = $FinalSceneStuff/AreaFinal/Marker3D.global_position
		$Player.rotation = $FinalSceneStuff/AreaFinal/Marker3D.rotation
		$ChaseDoors/FinalDoors.close()
		_on_it_ends_here_finished()
		

func _physics_process(delta):
	if fog_enabled:
		$FogPath/PathFollow3D.progress += fog_move_speed*delta

func add_a_message(text,color = "ffffff"):
	var text_inst = chat_message.instantiate()
	text_inst.text = text
	text_inst.modulate = Color(color)
	get_node("Player").chat.add_child(text_inst)

func _on_hide_the_tube_body_entered(body):
	$TubeMesh.hide()

func _on_teleport_to_top_body_entered(body):
	if body.name == "Player":
		times_fallen += 1
		body.global_position = $TeleportPosition.global_position
		if !Global.saw_chase_intro:
			if times_fallen == 1:
				$music.play()
				$Arrow.hide()
				show_part("Part2")
				await get_tree().create_timer(2.0).timeout
				entrance_dialogue()
			if times_fallen == 3:
				$SecretLabel.show()
			else:
				$SecretLabel.hide()

func entrance_dialogue():
	add_a_message("I will try removing any information they have on you",purple_color)
	await get_tree().create_timer(4.0).timeout
	add_a_message("But I cannot guarantee your safety even if I do succeed",purple_color)
	await get_tree().create_timer(4.0).timeout
	add_a_message("Try beating this level, it may count as a win",purple_color)
	Global.player.change_task("COMPLETE")

func create_camera_pixelization(camera_to_affect):
	if typeof(camera_to_affect) == TYPE_NODE_PATH:
		camera_to_affect = get_node(camera_to_affect)
	var effect_inst = pixel_effect.instantiate()
	camera_to_affect.add_child(effect_inst)
	effect_inst.position = Vector3(0,0,-0.1)

func show_part(part_name):
	if get_node_or_null(part_name) != null:
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		var part = get_node(part_name)
		tween.tween_property(part,"global_position",Vector3.ZERO,3.0)
	#part.global_position = Vector3.ZERO

func on_orb_collected():
	amount_collected += 1
	match_orb_count()

func match_orb_count():
	match amount_collected:
		1:
			await get_tree().create_timer(3.5).timeout
			add_a_message("I was created by Corsac as a replacement for their deathly ill boss, Spectator",purple_color)
			await get_tree().create_timer(4.5).timeout
			add_a_message("During my developement I quickly realized how inhumane Corsac are",purple_color)
			await get_tree().create_timer(4.5).timeout
			add_a_message("This is because I was based off an AI model that doesn't have sympathy for kidnappers",purple_color)
			await get_tree().create_timer(4.5).timeout
			add_a_message("This is also the same reason I was almost fully disabled and still lack a lot of features",purple_color)
		3:
			await get_tree().create_timer(2.0).timeout
			add_a_message("Corsac Team consists of three main members",purple_color)
			await get_tree().create_timer(3.5).timeout
			add_a_message("The Spectator[?],The Programmer[Jack],The Artist[Bill]",purple_color)
			await get_tree().create_timer(3.5).timeout
			add_a_message("Despite the name, Artist doesn't do the art",purple_color)
			await get_tree().create_timer(3.5).timeout
			add_a_message("He does most of the torture",purple_color)
		5:
			await get_tree().create_timer(2.0).timeout
			add_a_message("The terminal and the disk weren't suppossed to be in this version",purple_color)
			await get_tree().create_timer(3.5).timeout
			add_a_message("This means that The Programmer made a mistake and left it in",purple_color)
			await get_tree().create_timer(3.5).timeout
			add_a_message("or.",purple_color)
			await get_tree().create_timer(3.5).timeout
			add_a_message("He might be on your side",purple_color)
		7:
			await get_tree().create_timer(2.0).timeout
			show_part("Part7")
			$ChaseDoors.global_position = Vector3(0,0,0)
			add_a_message("I think a new island has appeared at the start",purple_color)

func show_chase_message(clue,time=0.25,no_effect=false):
	Engine.time_scale = 0.3
	$ChaseMusic.pitch_scale = 0.3
	var mess_inst = screen_message.instantiate()
	mess_inst.modulate = Color("9524e1")
	mess_inst.should_dissapear = false
	mess_inst.text = clue
	$ScreenMessages/BlackBg.modulate = Color(1,1,1,1)
	$ScreenMessages/BlackBg.show()
	$ScreenMessages/Efect.show()
	if no_effect:
		chase_player.start_thing()
	$ScreenMessages/ScreenMessagesHolder.add_child(mess_inst)
	await(get_tree().create_timer(time).timeout)
	#chase_player.speed = 0.0
	#chase_player.active = true
	$ChaseMusic.pitch_scale = 1.0
	Engine.time_scale = 1.0
	$ScreenMessages/Efect.hide()
	$ScreenMessages/BlackBg.hide()
	mess_inst.queue_free()

func saw_chase_intro():
	Global.saw_chase_intro = true

func player_died():
	get_tree().paused = true
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel(true)
	$ScreenMessages/BlackBg.modulate = Color("ffffff")
	$ScreenMessages/BlackBg.color = Color("000000")
	$ScreenMessages/ScareyText.show()
	$ScreenMessages/notyet.show()
	$ScreenMessages/Efect.show()
	$ScreenMessages/BlackBg.show()
	tween.parallel().tween_property($ScreenMessages/ScareyText,"modulate",Color("ffffff"),15.0)
	tween.parallel().tween_property($ScreenMessages/notyet,"modulate",Color("6604a69a"),6.5)
	$riser.play()
	await(get_tree().create_timer(6.5).timeout)
	tween.stop()
	$ScreenMessages/notyet.hide()
	$ScreenMessages/ScareyText.hide()
	$riser.stop()
	await(get_tree().create_timer(1.0).timeout)
	get_tree().reload_current_scene()

func chase_intro_dialogue():
		await get_tree().create_timer(1.0).timeout
		add_a_message("Hold on",purple_color)
		await get_tree().create_timer(1.0).timeout
		add_a_message("Something's not right",purple_color)
		await get_tree().create_timer(2.0).timeout
		add_a_message("",purple_color)
		await get_tree().create_timer(5.0).timeout
		show_chase_message("RUN",0.4,true)
		await get_tree().create_timer(0.4).timeout
		if Global.im_debugging_shit:
			pass
			#teleport_to_final()
		$ChasePlayer.active = false
		$ChasePlayer.activate()
		$ChaseMusic.play()
		$MusicSwitch.start(48.6)
		$MusicRestSwitch.start(88.9)
		$Player.change_pause(true)
		enable_fog()

func _on_music_switch_timeout():
	var part_mirror = $Part7.duplicate()
	part_mirror.name = "MirrorPart"
	part_mirror.scale = Vector3(1,-1,1)
	part_mirror.position = Vector3(0,20,0)
	add_child(part_mirror)
	default_environment = world_environment.environment.duplicate()
	var new_environemnt = world_environment.environment.duplicate()
	new_environemnt.set("fog_light_color","b10900")
	new_environemnt.set("fog_density",0.01)
	new_environemnt.set("fog_height_density",3.0)
	new_environemnt.set("adjustment_contrast",1.3)
	world_environment.environment = new_environemnt
	Global.saw_chase_switch = true
	$ChasePlayer.enable_particles()
	$ChasePlayer.camera_3d.add_trauma(3.0)

func start_from_red():
	$ChaseDoors/SwitchDoor.close()
	_on_music_switch_timeout()
	$ChasePlayer.position = $SwitchMarker.position
	$ChasePlayer.rotation = $SwitchMarker.rotation

func _on_chase_scene_trigger_body_entered(body):
	if !Global.saw_chase_intro:
		$AnimationPlayer.play("ChaseIntro")
	else:
		show_chase_message("RUN",0.4,true)
		await get_tree().create_timer(0.4).timeout
		$ChasePlayer.active = false
		$ChasePlayer.activate()
		if !Global.saw_chase_switch:
			$ChaseMusic.play()
			$MusicSwitch.start(48.6)
			$MusicRestSwitch.start(88.9)
		else:
			$ChaseMusic.play(48.6)
			$MusicRestSwitch.start(40.3)
			start_from_red()
		enable_fog()

func _on_music_rest_switch_timeout():
	world_environment.environment = default_environment
	get_node("MirrorPart").queue_free()
	$ChasePlayer.disable_particles()
	disable_fog()


func _on_fog_kill_zone_body_entered(body):
	if body.name == "ChasePlayer":
		#$FogView.make_current()
		player_died()

func enable_fog():
	$FogVolume.show()
	$FogVolume/FogKillZone.monitoring = true
	$FogVolume/FogKillZone.monitorable = true
	fog_enabled = true

func disable_fog():
	$FogVolume.hide()
	$FogVolume/FogKillZone.monitoring = false
	$FogVolume/FogKillZone.monitorable = false
	fog_enabled = false


func _on_area_final_body_entered(body):
	if body.name == "ChasePlayer":
		$FinalSceneStuff/AreaFinal.queue_free()
		$Player.can_pause = false
		$Player.global_position = $FinalSceneStuff/AreaFinal/Marker3D.global_position
		$Player.rotation = $FinalSceneStuff/AreaFinal/Marker3D.rotation
		$ChasePlayer.activate()
		$ChaseDoors/FinalDoors.close()
		start_monologue()
		if Global.im_debugging_shit:
			$ChaseMusic.stop()
			$MusicSwitch.stop()
			$MusicRestSwitch.stop()
			disable_fog()

func teleport_to_final():
	$ChasePlayer.global_position = $FinalSceneStuff/Teleport.global_position
	$ChasePlayer.rotation = $FinalSceneStuff/Teleport.rotation

func start_monologue():
	$FinalSceneStuff/VoiceLines/ItEndsHere.play()
	await(get_tree().create_timer(3.0).timeout)
	$FinalSceneStuff/VoiceLines/MonologueStart.play()

func _on_it_ends_here_finished():
	await(get_tree().create_timer(1.0).timeout)
	$FinalSceneStuff/VoiceLines/TimeToChoose.play()
	await(get_tree().create_timer(3.5).timeout)
	$Player.show_choice()

func coin_scene():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$FinalSceneStuff/VoiceLines/CoinFlipMusic2.play()
	await(get_tree().create_timer(2.0).timeout)
	$FinalSceneStuff/FinalAnimationPlayer.play("CoinAppear")

func _on_final_animation_player_animation_finished(anim_name):
	if anim_name == "CoinAppear":
		$FinalSceneStuff/FinalAnimationPlayer.play("CoinFlip")
	if anim_name == "CoinFlip":
		if !Global.has_flipped:
			var side = randi_range(1,2)
			if side == 1:
				$FinalSceneStuff/FinalAnimationPlayer.play("CoinLandTails")
			elif side == 2:
				$FinalSceneStuff/FinalAnimationPlayer.play("CoinLandHeads")
			Global.has_flipped = true
		else:
			if Global.did_win:
				if chosen_coin == "tails":
					$FinalSceneStuff/FinalAnimationPlayer.play("CoinLandHeads")
				if chosen_coin == "heads":
					$FinalSceneStuff/FinalAnimationPlayer.play("CoinLandTails")
			else:
				if chosen_coin == "tails":
					$FinalSceneStuff/FinalAnimationPlayer.play("CoinLandTails")
				if chosen_coin == "heads":
					$FinalSceneStuff/FinalAnimationPlayer.play("CoinLandHeads")

func coin_check(side:String):
	await(get_tree().create_timer(1.0).timeout)
	$FinalSceneStuff/VoiceLines/CoinFlipMusic2.stop()
	if side == "tails":
		$FinalSceneStuff/VoiceLines/Coine/Tails.play()
	else:
		$FinalSceneStuff/VoiceLines/Coine/Heads.play()
	
	await(get_tree().create_timer(2.0).timeout)
	
	Global.saw_coin_flip = true
	
	if side == chosen_coin:
		Global.did_win = true
		$FinalSceneStuff/VoiceLines/Coine/YouWon.play()
	else:
		Global.did_win = false
		$FinalSceneStuff/VoiceLines/Coine/YouLost.play()
	
	await(get_tree().create_timer(2.0).timeout)
	$FinalSceneStuff/FinalAnimationPlayer.play("FadeOut")
	$ScreenMessages/BlackBg.show()


func _on_goodbye_scott_finished():
	await(get_tree().create_timer(2.0).timeout)
	get_tree().change_scene_to_file("res://Scenes/Reality/ScottRoom.tscn")
