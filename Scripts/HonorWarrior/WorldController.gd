extends Node3D

var chat_message = preload("res://Scenes/HonorWarrior/ChatMessage.tscn")
var screen_message = preload("res://Scenes/HonorWarrior/ScreenMessage.tscn")

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

	load_doors()

func on_room_entered(room):
	var the_room = enemy_rooms.get_node("Room"+str(room))
	if get_node_or_null("Doors/Door" + str(room - 1)) != null:
		var previous_door = doors.get_node("Door" + str(room - 1))
		close_door(previous_door)
	while dead_enemies != amount_of_enemies:
		print("retrying")
		await get_tree().create_timer(1).timeout
	print("hey you did it")
	amount_of_enemies = 0
	dead_enemies = 0
	Global.emit_signal("passed_room",room)

func on_room_left(room):
	add_a_message("Player has completed room " + str(room))
	open_door_to_room(room)
	if level_name == "SnowLands":
		if room == 3:
			await get_tree().create_timer(3).timeout
			$VoiceLines/I_didnt_know.play()
			add_a_message("The Spectator has joined the game","ef7436")
			await $VoiceLines/I_didnt_know.finished
			add_screen_message("--- MICROPHONE STREAM LOST ---")
			get_node("Player").turn_off_sounds()
			await get_tree().create_timer(1.0).timeout
			$VoiceLines/AudioCutOff.play()
		if room == 4:
			await get_tree().create_timer(1).timeout
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
	await (get_tree().create_timer(3).timeout)
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

func saw_camera():
	Global.camera_on = !Global.camera_on

func _on_timer_timeout():
	$Video/Panel/Camera1.play()
