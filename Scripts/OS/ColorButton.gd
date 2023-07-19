extends Button

func _ready():
	connect("pressed",pressed)

func pressed():
	get_parent().get_parent().get_parent().selected_color = self.modulate
