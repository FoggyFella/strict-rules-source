extends Node3D

var terminal_active = false

var window_modes = [
	DisplayServer.WINDOW_MODE_FULLSCREEN,
	DisplayServer.WINDOW_MODE_WINDOWED,
	DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
]

var sfx_buses = [1,2,3,4,5]

var music_buses = [6,7]

func _ready():
	Global.should_play_input_sound = false
	setup_viewports()
	$UI/Settings.show()
	$UI/Settings.scale = Vector2(1,0)
	if Global.force_into_ex_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	set_correct_setting_values()
	await(get_tree().create_timer(1.0).timeout)
	$AnimationPlayer.play("Camera")
	await(get_tree().create_timer(4.5).timeout)
	turn_on_terminal()

func turn_on_terminal():
	terminal_active = true
	$YellowShit.show()
	$TerminalSoudns.play()
	$TerminalViewport/TerminalMenu.boot_up()
	$TerminalViewport/TerminalMenu/MainScreen/CommandBar/InputBar.grab_focus()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Camera":
		pass
		#$AnimationPlayer.play("CameraSway")

func _unhandled_input(event):
	if terminal_active:
		$TerminalViewport.push_input(event)

func setup_viewports():
	var logo_viewport_mat = StandardMaterial3D.new()
	logo_viewport_mat.albedo_texture = $LogoViewport.get_texture()
	$Stuffs/LogoPc.set_surface_override_material(2,logo_viewport_mat)
	
	$BloomViewport/TextureRect.texture = $TerminalViewport.get_texture()
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = $BloomViewport.get_texture()
	mat.emission_enabled = true
	mat.emission_texture = $BloomViewport.get_texture()
	mat.emission_energy_multiplier =4.3
	mat.roughness = 0.5
	mat.albedo_color = Color(1,1,1)
	$Stuffs/TerminalPc.set_surface_override_material(2,mat)

func on_start():
	terminal_active = false
	$AnimationPlayer.play("fade_in")

func on_settings():
	terminal_active = false
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($UI/Settings,"scale",Vector2(1,1),0.4)
	
func on_exit():
	terminal_active = false
	await(get_tree().create_timer(1.0).timeout)
	get_tree().quit()

func change_to_os():
	get_tree().change_scene_to_file("res://Scenes/OS/MainOsScreen.tscn")

func _on_close_settings_pressed():
	Global.emit_signal("settings_changed")
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($UI/Settings,"scale",Vector2(1,0),0.4)
	await(tween.finished)
	$TerminalViewport/TerminalMenu/MainScreen/CommandBar/InputBar.grab_focus()
	terminal_active = true

func _on_window_options_item_selected(index):
	DisplayServer.window_set_mode(window_modes[index])

func _on_pixelation_box_value_changed(value):
	Global.pixelization = value

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

func _on_sens_slider_value_changed(value):
	Global.sensitivity = value

func set_correct_setting_values():
	$UI/Settings/SettingsContainer/Music/MusicSlider.value = AudioServer.get_bus_volume_db(6)
	$UI/Settings/SettingsContainer/Sfx/SfxSlider.value = AudioServer.get_bus_volume_db(1)
	$UI/Settings/SettingsContainer/Sensitity/SensSlider.value = Global.sensitivity
	$UI/Settings/SettingsContainer/Pixelation/PixelationBox.value  = Global.pixelization
	
	var window_mode = DisplayServer.window_get_mode()
	
	if window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		$UI/Settings/SettingsContainer/Window/WindowOptions.select(0)
	elif window_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		$UI/Settings/SettingsContainer/Window/WindowOptions.select(2)
	elif window_mode == DisplayServer.WINDOW_MODE_WINDOWED:
		$UI/Settings/SettingsContainer/Window/WindowOptions.select(1)
