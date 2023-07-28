extends OmniLight3D

@onready var light_strength = light_energy

func _ready():
	randomize()
	$TimeUntilFlick.timeout.connect(_on_until_flick)
	$TimeUntilBack.timeout.connect(_on_until_back)
	$TimeUntilFlick.start(randf_range(2,8))

func flicker():
	randomize()
	light_energy = 0.0
	get_parent().get_active_material(2).albedo_color = Color(0,0,0,1)
	$TimeUntilBack.start(randf_range(0.5,1.1))

func _on_until_flick():
	flicker()

func _on_until_back():
	randomize()
	light_energy = light_strength
	get_parent().get_active_material(2).albedo_color = Color(1,1,1,1)
	$TimeUntilFlick.start(randf_range(4,8))
