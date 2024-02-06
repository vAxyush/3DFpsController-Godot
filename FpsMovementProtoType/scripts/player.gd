extends CharacterBody3D

# Variables

# Speed Variables

var speed

# Field Of View

const default_fov = 75.0
const additional_fov = 1.5

# const variables

const sprint_Speed = 8.0
const walkSpeed = 5.0
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const Sensitivity = 0.004
const crouchingSpeed = 3.0

# onready variables

@onready var Neck = $Neck
@onready var Camera = $Neck/Camera3D

# Bob Variables

const Bob_Amp = 0.08 # Maximum bob
var Bobb = 0.0
const Bob_Frequency = 2.0 # How often we walk



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # it captures the mouse cursor

func _unhandled_input(event):
	# unhandled input event is called if any action occurs
	if event is InputEventMouseMotion:
		Neck.rotate_y(-event.relative.x * Sensitivity)
		Camera.rotate_x(-event.relative.y * Sensitivity)
		Camera.rotation.x = clamp(Camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta):
	
	# Exit function
	
	if Input.is_action_pressed("exit"):
		get_tree().quit()
	
	# Sprint Mechanics
	
	if Input.is_action_pressed("run"):
		speed = sprint_Speed
	else:
		speed = walkSpeed
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (Neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		velocity.x = lerp(velocity.x,direction.x * speed,delta * 2.0)
		velocity.z = lerp(velocity.z,direction.z * speed,delta * 2.0)

	# Bobbing Mechanics
	
	Bobb += delta * velocity.length() * float(is_on_floor())
	Camera.transform.origin = _headbob(Bobb)
	
	# Sway
	
	if input_dir.x > 0:
		Camera.rotation.z = lerp_angle(Camera.rotation.z , deg_to_rad(-3) , 0.5)
	if input_dir.x < 0:
		Camera.rotation.z = lerp_angle(Camera.rotation.z , deg_to_rad(3) , 0.5)
	else:
		Camera.rotation.z = lerp_angle(Camera.rotation.z , deg_to_rad(0) , 0.5)
	
	# Fov Mechanics	

	var velocity_clamped = clamp(velocity.length() , 0.5 , sprint_Speed * 2)
	var target_fov = default_fov + additional_fov * velocity_clamped
	
	# Assinging Fov to camera
	
	Camera.fov = lerp(Camera.fov , target_fov , delta * 2.0)
	
	move_and_slide()


func _headbob(time) -> Vector3 : 
	var pos = Vector3.ZERO
	pos.y = sin(time * Bob_Frequency) * Bob_Amp # Vertical Bob
	pos.x = cos(time * Bob_Frequency / 2) * Bob_Amp
	return pos
