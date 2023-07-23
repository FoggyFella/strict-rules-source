extends Area3D

@onready var world = get_tree().current_scene

@export var pc_camera:Camera3D
@export var pc_itself:MeshInstance3D
@export var the_os_thing:Control
@export var the_viewport:SubViewport

var can_interact = true

var can_leave = true
var active = false
var active_light_color = "00ac34"

func _ready():
	$CanvasLayer.hide()

func _on_body_entered(body):
	if can_interact:
		active = true
		$CanvasLayer.show()


func _on_body_exited(body):
	if can_interact:
		active = false
		$CanvasLayer.hide()

func _unhandled_input(event):
	if event.is_action_pressed("interact") and active:
		active = false
		$CanvasLayer.hide()
		pc_camera.make_current()
		Global.player.turn_off_camera()
		turn_on_pc_light()
		the_os_thing.boot_up()
		Global.player.can_pause = false
	if event.is_action_pressed("ui_cancel") and !active and can_leave and the_os_thing.turned_on:
		the_os_thing.turned_on = false
		Global.player.turn_on_camera()
		turn_off_pc_light()
		the_os_thing.clear_shit()
		await(get_tree().create_timer(1.0).timeout)
		Global.player.can_pause = true
	#the_viewport.push_unhandled_input(event)
	the_viewport.push_input(event)
	#if event.is_action_pressed("ui_accept") and pc_itself.get_node("Light").visible:
		#the_os_thing._on_input_bar_text_submitted(the_os_thing.input_bar.text)

func turn_on_pc_light():
	var mat_screen = pc_itself.get_surface_override_material(2)
	var mat_light = pc_itself.get_surface_override_material(0)
	mat_screen.set("albedo_color",Color(1,1,1))
	mat_light.set("emission",Color(active_light_color))
	pc_itself.get_node("Light").show()
	#pc_itself.set_surface_override_material(0,mat_light)
	#pc_itself.set_surface_override_material(2,mat_screen)

func turn_off_pc_light():
	var mat_screen = pc_itself.get_surface_override_material(2)
	var mat_light = pc_itself.get_surface_override_material(0)
	mat_screen.set("albedo_color",Color(0,0,0))
	mat_light.set("emission",Color(0,0,0))
	pc_itself.get_node("Light").hide()
	#pc_itself.set_surface_override_material(0,mat_light)
	#pc_itself.set_surface_override_material(2,mat_screen)

func force_out():
	can_interact = false
	active = false
	$CanvasLayer.hide()
	Global.player.turn_on_camera()
	turn_off_pc_light()
	the_os_thing.clear_shit()
	world.arc_dialogue_mines()
