extends StaticBody3D

@export var dissapear_distance : float = 5.0
@export var dissapear_sound: String = "Snow"

@onready var until_gone = $untilGone
var ray = null
var player = null

func _ready():
	await get_tree().physics_frame
	player = Global.player

func _physics_process(delta):
	if player == null:
		return
	var distance = global_position.distance_to(player.global_position)
	if distance < dissapear_distance:
		_on_until_gone_timeout()

func on_entered(ray_entered):
	pass
#	ray = ray_entered
#	if until_gone.is_stopped():
#		until_gone.start()

func _on_until_gone_timeout():
	if !get_node(dissapear_sound).playing:
		$Someone.hide()
		get_node(dissapear_sound).play()
		await get_node(dissapear_sound).finished
		queue_free()
