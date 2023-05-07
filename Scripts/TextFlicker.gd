extends TextureRect

@onready var original_color = modulate

func _ready():
	randomize()
	$TimeUntilFlick.timeout.connect(on_until_flick)
	$TimeUntilBack.timeout.connect(on_until_back)
	$TimeUntilFlick.start(randf_range(6,10))


func on_until_flick():
	modulate = Color(0,0,0,1)
	$TimeUntilBack.start(randf_range(0.4,0.9))

func on_until_back():
	randomize()
	modulate = original_color
	$TimeUntilFlick.start(randf_range(6,11))
