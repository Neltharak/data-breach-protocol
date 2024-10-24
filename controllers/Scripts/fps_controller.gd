extends CharacterBody3D


const SPEED = 10.0
const JUMP_VELOCITY = 7.0

@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Camera3D
@export var MOUSE_SENSITIVITY : float = 0.5

var _mouse_input : bool = false
var _mouse_rotation : Vector3
var _rotation_input : float
var _tilt_input : float
var _can_double_jump : bool = false
var _player_rotation : Vector3 
var _camera_rotation : Vector3

func _input(event: InputEvent):
	if event.is_action_pressed("exit"):
		get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
		print(Vector2(_rotation_input, _tilt_input))

func _update_camera(delta):
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT) 
	_mouse_rotation.y += _rotation_input * delta

	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)

	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	CAMERA_CONTROLLER.rotation.z = 0.0

	global_transform.basis = Basis.from_euler(_player_rotation)
	_rotation_input = 0.0
	_tilt_input = 0.0

func _can_jump() -> bool:
	if is_on_floor():
		_can_double_jump = true
		return true
	elif _can_double_jump:
		return true
	return false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	_update_camera(delta)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and _can_jump():
		if not is_on_floor():
			_can_double_jump = false

		velocity.y = JUMP_VELOCITY
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
