extends CharacterBody3D


@export var can_move:bool = true
@export var can_interact:bool = true

@export var SPEED = 5.0

@export var BOB_FREQ = 2.4
@export var BOB_AMP = 0.08
@export var time_between_steps = 0.1

var t_bob = 0.0

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head := $Head
@onready var camera := $Head/Camera3D
@onready var label = $UI/Label

func _ready():
	$Reference.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			head.rotate_y(-event.relative.x * Global.sensitivity)
			camera.rotate_x(-event.relative.y * Global.sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP,head.global_rotation.y).normalized()
	if direction and can_move:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if is_on_floor() and $FootstepTimer.is_stopped():
			$FootstepTimer.start(time_between_steps)
	else:
		$FootstepTimer.stop()
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = headbob(t_bob)
	
	move_and_slide()
	do_ray_checks()

func headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func _on_footstep_timer_timeout():
	randomize()
	$FootStepSound.pitch_scale = randf_range(0.9,1.1)
	$FootStepSound.play()

func disable_movement():
	can_move = false
	can_interact = false

func enable_movement():
	can_move = true
	can_interact = true

func switch_camera():
	$InterpolatedCamera3D.make_current()

func do_ray_checks():
	label.text = ""
	if $Head/Camera3D/ObjectRay.is_colliding() and can_interact:
		var detected_thing = $Head/Camera3D/ObjectRay.get_collider()
		
		if detected_thing is Interactable and !detected_thing.interacted_already:
			label.text = detected_thing.name+"\n Press E to interact"
			
			if Input.is_action_just_pressed("interact"):
				detected_thing.interaction()
