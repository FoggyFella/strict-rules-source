extends Node2D

@onready var bricks = $Bricks

var ball = preload("res://Scenes/Bricker/ball.tscn")

var ball_count = 0
var bricks_count = 0

var lives_left = 4

func _ready():
	bricks_count = bricks.get_children().size()

func _process(delta):
	var window_size = DisplayServer.window_get_size()
	$LeftWall.scale.y = window_size.y* window_size.y
	$LeftWall.position.y = window_size.y
	$RightWall.scale.y = window_size.y* window_size.y
	$RightWall.position.y = window_size.y
	$RightWall.position.x = get_viewport_rect().end.x
	$Ceiling.position.y = 1.0
	$Ceiling.scale.y = get_viewport_rect().end.x*2

func _physics_process(delta):
	$Paddle.position.y = get_viewport_rect().end.y*0.9
	$Paddle.velocity = Vector2($Paddle.get_local_mouse_position().x*4.0,0.0)
	$Paddle.move_and_slide()
	
	if Input.is_action_just_pressed("shoot") and ball_count == 0:
		$Shoot.pitch_scale = randf_range(0.9,1.2)
		$Shoot.play()
		ball_count += 1
		var ball_inst = ball.instantiate()
		ball_inst.position = $Paddle/Marker2D.global_position
		get_tree().current_scene.add_child(ball_inst)
		if $Paddle.get_local_mouse_position().x > 0.0:
			ball_inst.linear_velocity = Vector2($Paddle.velocity.x,-1000)
		else:
			ball_inst.linear_velocity = Vector2($Paddle.velocity.x,-1000)
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func life_lost():
	$LifeLost.play()
	lives_left -= 1
	if lives_left <= 0:
		get_tree().reload_current_scene()
