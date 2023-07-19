extends Node3D

@export var can_be_opened = true
@export var break_open = true
@export var anim_speed = 4.0

@onready var animation_player = $AnimationPlayer

func _ready():
	$AnimationPlayer.speed_scale = anim_speed

func _on_detection_area_body_entered(body):
	if can_be_opened:
		randomize()
		if break_open:
			$BreakOpen.pitch_scale = randf_range(0.8,1.2)
			$BreakOpen.play()
		else:
			$NormalOpen.pitch_scale = randf_range(0.9,1.1)
			$NormalOpen.play()
		$DetectionArea.queue_free()
		animation_player.play("open")

func close():
	$AnimationPlayer.play("RESET")