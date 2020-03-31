extends KinematicBody

class_name Player

export var speed = 70
export var friction = 0.85
export var gravity = 80
export var jump_impulse = 30
export var mouse_sensitivity = 0.3
export var climb_speed = 50
var do_climb = false

onready var head = $Head
onready var camera = $Head/Camera

var vel = Vector3()
var camera_x_rotation = 0 # keep track of camera rotation to avoid overlooking upside down
var camera_change = Vector2()

var sprint_modifier = 1.0

func _ready():
	G.PlayerNode = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		camera_change = event.relative # Capture mouse movement, save it to variable which will be used in aim()
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
func _physics_process(delta):
	aim()
	sprint()
	walk(delta)
	jump(delta)
	climb(delta)
	vel = move_and_slide(vel, Vector3.UP, true, 4)


func aim():
	if not camera_change.length(): return # if mouse was moved and camera needs to turn
	head.rotate_y(deg2rad(-camera_change.x * mouse_sensitivity)) # Rotate horizontally
	camera.rotate_x(deg2rad(-camera_change.y * mouse_sensitivity)) # Rotate vertically
	camera.rotation.x = clamp(camera.rotation.x,-1.2,1.2) # Limit vertical rotation to 90 degrees
	camera_change = Vector2() # Reset camera change after it has been performed

	
func walk(delta):
	var head_rotation = head.get_global_transform().basis
	
	var move_direction = Vector3()
	if Input.is_action_pressed("move_forward"):
		move_direction -= head_rotation.z
	elif Input.is_action_pressed("move_back"):
		move_direction += head_rotation.z
	if Input.is_action_pressed("move_left"):
		move_direction -= head_rotation.x
	elif Input.is_action_pressed("move_right"):
		move_direction += head_rotation.x
	move_direction = move_direction.normalized()
	
	vel += move_direction*speed*delta*$Head/Camera/Weapon.scoping_modifier*sprint_modifier
	vel *= friction
	vel.y -= gravity*delta*int(not do_climb)


func jump(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		vel.y += jump_impulse*sprint_modifier

func climb(delta):
	if do_climb and Input.is_action_pressed("move_forward"):
		vel.y += climb_speed*delta
		
func sprint():
	if Input.is_action_pressed("sprint") and $Health.current_energy > 0:
		sprint_modifier = 2.5
		$Health.discharge(1)
	else:
		sprint_modifier = 1

func take_damage(damage):
	$Health.take_damage(damage)

func heal(amount):
	$Health.heal(amount)
