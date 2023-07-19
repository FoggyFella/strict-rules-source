extends Panel

@onready var lines_root = $Lines

var pressed = false
var current_line:Line2D

var line_template = preload("res://Scenes/OS/Painto shit/SphereLine.tscn")

var width = 5
var selected_color = Color("000000")
var should_curve = false
var joints = "Round"

func _process(delta):
	if Input.is_action_just_pressed("reverse"):
		if lines_root.get_child_count() > 0:
			lines_root.get_child(lines_root.get_child_count()-1).queue_free()
	if get_parent().drag_position != null and current_line != null:
		current_line.queue_free()
		
func _input(event):
	if get_parent().drag_position == null and get_parent().scale > Vector2(0.5,0.5):
		if event is InputEventMouseButton:
			pressed = event.pressed
			if pressed and event.button_index == MOUSE_BUTTON_LEFT:
				current_line = line_template.instantiate()
				lines_root.add_child(current_line)
				current_line.owner = get_tree().current_scene
		if event is InputEventMouseMotion && pressed && get_parent().drag_position == null && current_line != null:
			current_line.add_point(get_local_mouse_position())
			current_line.default_color = selected_color
			current_line.width = width
			$ColorPickerButton.color = selected_color


func _on_color_picker_button_color_changed(color):
	selected_color = color
