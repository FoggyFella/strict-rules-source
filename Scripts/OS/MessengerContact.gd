extends Button

@onready var the_parent = $"../../../.."

func _ready():
	pressed.connect(on_pressed)

func on_pressed():
	the_parent.display_messages_from(self.text)
