extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 7
const DASH_VELOCITY = 20
const DASH_COOLDOWN = 40
var dash_time = DASH_COOLDOWN
var dash_max = 1
var dash_count = dash_max
const SENSITIVITY = 0.008

const coyote_max = 15
var coyote_time = coyote_max

#bob variables
const BOB_FREQ = 2.5
const BOB_AMP = 0.08
var t_bob = 0.0

#fov variables
const BASE_FOV = 70.0
const FOV_CHANGE = 4

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 15;

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		coyote_time = coyote_max

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and coyote_time > 0:
		velocity.y = JUMP_VELOCITY
		coyote_time = 0
		
	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	
	if is_on_floor():
		dash_count = dash_max
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		coyote_time -= 1
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 4.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 4.0)
	
	# Handle Dash?
	if Input.is_action_just_pressed("dash") and dash_count > 0 and not is_on_floor():
		dash_count -= 1
		dash_time = 0
		velocity.x = direction.x * DASH_VELOCITY
		velocity.z = direction.z * DASH_VELOCITY
		
		if Input.is_action_pressed("up"):
			velocity.y = camera.rotation.x * (DASH_VELOCITY / 2)
		elif Input.is_action_pressed("down"):
			velocity.y = -(camera.rotation.x * (DASH_VELOCITY / 2)) + 1
	
	if dash_time < DASH_COOLDOWN: dash_time += 1
	
	# Terminal Velocity
	if velocity.y >= 10: velocity.y = 10
	elif velocity.y <= -15: velocity.y = -15
	
	# Head Bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), WALK_SPEED, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.8)

	if coyote_time < 0: coyote_time = 0
	move_and_slide()
	print(velocity.y)
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO;
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
