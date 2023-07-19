extends Button

@export var line:PackedScene

func _ready():
	connect("pressed",pressed)
	
func pressed():
	get_parent().get_parent().line_template = line
