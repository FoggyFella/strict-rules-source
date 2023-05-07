extends Button

@export var screen_path:NodePath
@export var voice_line_path:NodePath
var screen = null
var voice_line = null

func _ready():
	screen = get_node_or_null(screen_path)
	voice_line = get_node_or_null(voice_line_path)
	self.pressed.connect(on_pressed)

func on_pressed():
	if screen != null:
		voice_line = get_node_or_null(voice_line_path)
		screen.open()
		if voice_line != null:
			if voice_line.playing == false:
				voice_line.play()
				await voice_line.finished
				voice_line.queue_free()
