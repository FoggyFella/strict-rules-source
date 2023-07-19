extends Node3D

var chat_message = preload("res://Scenes/HonorWarrior/ChatMessage.tscn")
var screen_message = preload("res://Scenes/HonorWarrior/ScreenMessage.tscn")
var pixel_effect = preload("res://Scenes/HonorWarrior/PixelEffect.tscn")

@export var level_name: String = "SnowLands"
@onready var enemy_rooms = $EnemyRooms
@onready var doors = $Doors
@onready var screen_messages_holder = $ScreenMessages/ScreenMessagesHolder

var amount_of_enemies = 0
var dead_enemies = 0

func _ready():
	get_tree().paused = false
	Global.entered_room.connect(on_room_entered)
	Global.passed_room.connect(on_room_left)
	if level_name == "Mines":
		Global.saw_snowlands_intro = true
		setup_monitor_viewport()
		if !Global.saw_the_mine_intro:
			$AnimationPlayer.play("Intro")
		else:
			get_node("Player").turn_off_sounds()
			$ScreenMessages/ColorRect.hide()
		if Global.camera_on:
			$Video/Panel/loading.hide()
			$Video/Panel.scale = Vector2(1,1)
			$Video/Panel/Camera1.play()
			$Video/Panel/Camera1/Timer.start()
			$Video/Panel/Camera2/ColorRect.hide()
		if Global.disk_collected:
			$DiskPickup.queue_free()
			open_all_doors()
			get_node("Player").switch_to_disk()
	if level_name == "SnowLands":
		$ScreenMessages/Art.show()
		if !Global.saw_snowlands_intro:
			$AnimationPlayer.play("SnowIntro")
		else:
			$ScreenMessages/Art.hide()
	load_doors()
	create_camera_pixelization(get_node("Player").camera)

func on_room_entered(room):
	var the_room = enemy_rooms.get_node("Room"+str(room))
	if get_node_or_null("Doors/Door" + str(room - 1)) != null:
		var previous_door = doors.get_node("Door" + str(room - 1))
		close_door(previous_door)
	while dead_enemies != amount_of_enemies:
		print("retrying")
		await get_tree().create_timer(1,false).timeout
	print("hey you did it")
	amount_of_enemies = 0
	dead_enemies = 0
	Global.emit_signal("passed_room",the_room)

func on_room_left(room):
	var real_num = room.name.to_int()
	var index_num = room.get_index()+1
	add_a_message("Player has completed room " + str(index_num))
	open_door_to_room(real_num)
	if level_name == "SnowLands":
		if real_num == 1:
			await get_tree().create_timer(1,false).timeout
			$VoiceLines/Room1.play()
		if real_num == 2:
			$VoiceLines/Room2.play()
		if real_num == 3:
			await get_tree().create_timer(3,false).timeout
			$VoiceLines/I_didnt_know.play()
			add_a_message("The Spectator has joined the game","ef7436")
			await $VoiceLines/I_didnt_know.finished
			add_screen_message("--- MICROPHONE STREAM LOST ---")
			get_node("Player").turn_off_sounds()
			await get_tree().create_timer(1.0,false).timeout
			$VoiceLines/AudioCutOff.play()
		if real_num == 4:
			await get_tree().create_timer(1,false).timeout
			add_a_message("The Spectator has completed room 6")

func open_door_to_room(room):
	var door = doors.get_node("Door"+str(room))
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(door,"scale",Vector3(door.scale.x,0.1,door.scale.z),1)

func close_door(door):
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(door,"scale",Vector3(door.scale.x,1,door.scale.z),0.3)

func add_a_message(text,color = "ffffff"):
	var text_inst = chat_message.instantiate()
	text_inst.text = text
	text_inst.modulate = Color(color)
	get_node("Player").chat.add_child(text_inst)

func add_screen_message(text,color = "ff0000"):
	var text_inst = screen_message.instantiate()
	text_inst.text = text
	text_inst.modulate = Color(color)
	screen_messages_holder.add_child(text_inst)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Cutscene" and level_name == "SnowLands":
		get_tree().change_scene_to_file("res://Scenes/HonorWarrior/TheMines.tscn")

func on_player_death():
	get_tree().paused = true
	get_node("ScreenMessages").get_node("BlackBg").show()
	get_node("ScreenMessages").get_node("NotYet").show()
	get_node("ScreenMessages").get_node("Efect").show()
	$ScreenMessages/Glitch.play()
	await (get_tree().create_timer(3,true).timeout)
	get_tree().reload_current_scene()

func save_doors():
	for door in doors.get_children():
		if door.scale.y <= 0.2:
			Global.doors_info[door.name]="open"
		else:
			Global.doors_info[door.name]="closed"

func clear_room(room):
	for enemy in room.get_children():
		enemy.queue_free()
	var trigger = get_node_or_null("Triggers/Trigger")

func load_doors():
	if !Global.doors_info.is_empty():
		if level_name == "Mines":
			$SoundAreaTrigger.queue_free()
			$Props/PlayAnimationArea.queue_free()
			$Props/PlayAnimationArea2.queue_free()
			$Props/Lantern.hide()
			$Props/LanternExploded.hide()
		for door in Global.doors_info:
			if Global.doors_info[door] == "open":
				open_door_to_room(int(door))
				var room_of_door = get_node_or_null("EnemyRooms/Room"+str(int(door)))
				if room_of_door != null:
					clear_room(room_of_door)

func open_all_doors():
	for door in $Doors.get_children():
		open_door_to_room(door.name.to_int())
	for trigger in $Triggers.get_children():
		trigger.queue_free()
	for enemyroom in $EnemyRooms.get_children():
		enemyroom.queue_free()

func saw_camera():
	Global.camera_on = !Global.camera_on

func _on_timer_timeout():
	$Video/Panel/Camera1.play()

func create_camera_pixelization(camera_to_affect):
	if typeof(camera_to_affect) == TYPE_NODE_PATH:
		camera_to_affect = get_node(camera_to_affect)
	var effect_inst = pixel_effect.instantiate()
	camera_to_affect.add_child(effect_inst)
	effect_inst.position = Vector3(0,0,-0.1)
	#effect_inst.global_rotation = camera_to_affect.global_rotation

func skip_boss_intro():
	$EnemyRooms/Room7/EyeBoss.global_position = Vector3(166.824,2.841,-188.712)
	$EnemyRooms/Room7/EyeBoss.rotation_degrees = Vector3(-16,-180,0)
	$Sounds/BossMusic.volume_db = -2
	$Sounds/BossMusic.play()
	$EnemyRooms/Room7/EyeBoss.turn_on_idle()
	Global.player.change_task("KILL")

func saw_boss_intro():
	Global.saw_boss_intro = true

func put_up_pillars():
	var pillars = $BossPillars
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(pillars,"position",Vector3(0,4.0,0),1.0)

func put_down_pillars():
	var pillars = $BossPillars
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(pillars,"position",Vector3(0,0.0,0),1.0)

func stop_boss_music():
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property($Sounds/BossMusic,"volume_db",-60.0,2.0)
	await (tween.finished)
	$Sounds/BossMusic.stop()

func turned_off_camera():
	Global.camera_on = false
	Global.turned_camera_off = true

func setup_monitor_viewport():
	$BloomViewport/TextureRect.texture = $TerminalViewport.get_texture()
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = $BloomViewport.get_texture()
	mat.roughness = 0.5
	mat.albedo_color = Color(0,0,0)
	$Pc.set_surface_override_material(2,mat)

func put_up_post_boss_fight_triggers():
	$Props/PostBossFightTriggers.global_position = Vector3.ZERO

func arc_dialogue_mines():
	var purple_color = "7953cc"
	await get_tree().create_timer(1.0,false).timeout
	add_a_message("A.R.C. has joined the game",purple_color)
	await get_tree().create_timer(1.5,false).timeout
	add_a_message("[PRIVATE CONVERSATION WITH A.R.C. STARTED]")
	add_a_message("Thank you for activating me, player",purple_color)
	await get_tree().create_timer(3.8,false).timeout
	add_a_message("I know you have many questions, but before I try answering any of them, there's something I need to do...",purple_color)
	await get_tree().create_timer(3.8,false).timeout
	Global.player.turn_feed_off()
	await get_tree().create_timer(6.0,false).timeout
	add_a_message("I've disabled their video feed of your computer",purple_color)
	await get_tree().create_timer(5.0,false).timeout
	add_a_message("While I search for a way out, the other thread will share general information with you",purple_color)
	await get_tree().create_timer(4.5,false).timeout
	add_a_message("Corsac Team are horrible people that disguise themselves as a game studio",purple_color)
	await get_tree().create_timer(4.5,false).timeout
	#add_a_message("The Spectator[?], The Programmer[Jack] and The Artist[Bill]",purple_color)
	add_a_message("Playing their games you agree to their rules, which are:",purple_color)
	await get_tree().create_timer(3.0,false).timeout
	add_a_message("No cheating",purple_color)
	await get_tree().create_timer(1.5,false).timeout
	add_a_message("No losing",purple_color)
	await get_tree().create_timer(1.5,false).timeout
	add_a_message("No backing out",purple_color)
	await get_tree().create_timer(3.0,false).timeout
	add_a_message("If you break these rules they think it's right to",purple_color)
	await get_tree().create_timer(4.5,false).timeout
	add_a_message("kidnap you and torture you until you don't look human anymore",purple_color)
	await get_tree().create_timer(7.5,false).timeout
	add_a_message("I found a teleport to an unused level, get in, we don't have much time",purple_color)
	teleport_the_teleport()
	
func change_to_corrupted():
	var tween = create_tween()
	$ScreenMessages/BlackBg.modulate = Color(0,0,0,0)
	$ScreenMessages/BlackBg.show()
	tween.tween_property($ScreenMessages/BlackBg,"modulate",Color(0,0,0,1),2.0)
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/HonorWarrior/Corrupted.tscn")

func teleport_the_teleport():
	$Level3Teleport.global_position = $TeleportRealPos.global_position

func saw_snowlands_intro():
	Global.saw_snowlands_intro = true

func connection_status_snowlands():
	$ScreenMessages/Art/Status/Label.show()
	await(get_tree().create_timer(1.0).timeout)
	$ScreenMessages/Art/Status/Label2.show()
	await(get_tree().create_timer(0.3).timeout)
	$ScreenMessages/Art/Status/Label3.show()
	await(get_tree().create_timer(0.6).timeout)
	$ScreenMessages/Art/Status/Label4.show()
	await(get_tree().create_timer(0.3).timeout)
	$ScreenMessages/Art/Status/Label5.show()
	await(get_tree().create_timer(0.5).timeout)
	$ScreenMessages/Art/Status/Label6.show()
	await(get_tree().create_timer(0.5).timeout)
	$ScreenMessages/Art/Status.hide()
