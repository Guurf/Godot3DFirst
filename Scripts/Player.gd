extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0

const JUMP_VELOCITY = 7
const POUND_VELOCITY = -10
var pounded = 0
var pound_length = 0
var pound_timer = 0
const DASH_VELOCITY = 20
const DASH_COOLDOWN = 40


const SENSITIVITY = 0.008
var dash_time = DASH_COOLDOWN
var dash_max = 1
var dash_count = dash_max


const coyote_max = 15
var coyote_time = coyote_max

#bob variables
const BOB_FREQ = 2.5
const BOB_AMP = 0.08
var t_bob = 0.0

var cam_tilt = 0

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
		if pounded == 1: 
			pound_length += 1
	else:
		if pounded == 1 && pound_timer > 0: pound_timer -= 1
		elif pound_timer <= 0: 
			pounded = 0
			pound_length = 0
		coyote_time = coyote_max

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and coyote_time > 0:
		if pound_length > 6: velocity.y = JUMP_VELOCITY + 5.2
		else: velocity.y = JUMP_VELOCITY
		pound_timer = 0
		pound_length = 0
		#pounded = 0
		coyote_time = 0
		
	print ("Jump height:", JUMP_VELOCITY + (pound_length))
		
	# Handle Sprint.
	if pounded == 1 and is_on_floor(): 
		speed = 2
	elif pounded == 1 and not is_on_floor(): 
		speed = 4
	elif Input.is_action_pressed("sprint"):
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
	
	# Handle Dash.
	if Input.is_action_just_pressed("dash") and dash_count > 0 and not is_on_floor():
		dash_count -= 1
		dash_time = 0
		velocity.x = direction.x * DASH_VELOCITY
		velocity.z = direction.z * DASH_VELOCITY
		velocity.y = 3
		#if Input.is_action_pressed("up"):
		#	velocity.y = camera.rotation.x * (DASH_VELOCITY / 2)
		#elif Input.is_action_pressed("down"):
		#	velocity.y = -(camera.rotation.x * (DASH_VELOCITY / 2)) + 1
	
	if dash_time < DASH_COOLDOWN: dash_time += 1
	
	# Handle Pound.
	if Input.is_action_just_pressed("crouch") and not is_on_floor():
		velocity.y = POUND_VELOCITY
		pounded = 1
		pound_timer = 15
	print("POUNDED?: ", pounded)
	print("Length: ", pound_length)
	# Terminal Velocity
	if velocity.y >= 15: velocity.y = 15
	elif velocity.y <= -15: velocity.y = -15
	
	# Head Bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# Head Tilt
	if Input.is_action_pressed("left"):
		cam_tilt += lerpf(0.0, 5, 0.05)
	elif Input.is_action_pressed("right"):
		cam_tilt -= lerpf(0.0, 5, 0.05)
	else:
		cam_tilt = lerpf(head.rotation_degrees.z, 0.0, 0.2)
		if cam_tilt >= -0.1 and cam_tilt <= 0.1: cam_tilt = int(0.0)
	cam_tilt = clamp(cam_tilt, -2, 2)
	head.rotation.z = deg_to_rad(cam_tilt)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), WALK_SPEED-2, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.8)

	if coyote_time < 0: coyote_time = 0
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO;
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP * 2
	return pos
