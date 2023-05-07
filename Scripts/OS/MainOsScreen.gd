extends Control

var can_move_mouse = false
@onready var mouse_def_pose = $Blastin.get_global_mouse_position()

func _ready():
	randomize()
	$"THIS HAS TO BE ON TOP OF EVERYTHING".show()
	$BlacKScreen.show()

func _input(event):
	if event is InputEventMouseMotion and !can_move_mouse:
		warp_mouse(mouse_def_pose)

func enable_mouse():
	$BlacKScreen.mouse_filter = MOUSE_FILTER_IGNORE
	can_move_mouse = true
