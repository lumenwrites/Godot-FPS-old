extends Spatial

export var clip_size = 15
var current_ammo = 0
export var fire_rate = 0.12
export var reload_rate = 1.0 # how long it takes to reload
export var max_range = 80
export var max_damage = 40
export var min_damage = 10
export var min_spread = 0.1
export var max_spread = 10
var current_spread = 0.0
export var recoil_strength = 0.75
var current_recoil = 0.0
export var default_fov = 70.0
export var scoped_fov = 25.0
var scoping_modifier = 1.0 # used to modify spread, recoil, walking speed
var running_modifier = 1.0 # increase spread when running

var can_fire = true
var reloading = false

onready var raycast = $RayCast
onready var camera = owner.get_node("Head/Camera")
onready var HUD = get_tree().get_root().get_node("World/HUD")
const BULLET_HOLE = preload("res://Weapons/BulletHole.tscn")

func _ready():
	raycast.cast_to = Vector3(0,0, -max_range)
	current_ammo = clip_size
	current_spread = min_spread
	HUD.update_ammo(self)
	
func _input(event):
	if event is InputEventMouseMotion and event.relative.y > 0 and current_recoil > 0:
		# If the player moves the mouse down to compensate for recoil
		current_recoil -= event.relative.y *  G.PlayerNode.mouse_sensitivity

func _physics_process(delta):
	if Input.is_action_pressed("fire") and can_fire and not reloading:
		if current_ammo > 0: 
			fire()
		else: 
			reload()
			
	if Input.is_action_just_pressed("reload"): 
		reload()
		
	if not Input.is_action_pressed("fire") or reloading: # If I'm not firing
		if current_recoil > 0: # Gradually decrease recoil
			current_recoil -= 0.25
			camera.rotate_x(deg2rad(-0.25))
		if current_spread > 0:  # Gradually decrease spread
			current_spread = lerp(current_spread, min_spread, 0.1)
		raycast.rotation = Vector3(0,0,0)
		
	scope()
	
	if G.PlayerNode.vel.length() > 5:
		running_modifier = 2.0
	else:
		running_modifier = 1.0


func fire():
	spread()
	deal_damage()
	
	current_ammo -= 1
	HUD.update_ammo(self)
	
	current_recoil += recoil_strength * scoping_modifier
	camera.rotate_x(deg2rad(recoil_strength * scoping_modifier))

	$AudioStreamPlayer.stream = load("res://Assets/sounds/gunshot.wav")
	$AudioStreamPlayer.play()
	
	can_fire = false
	yield(get_tree().create_timer(fire_rate), "timeout") # wait until timer times out
	can_fire = true


func reload():	
	reloading = true
	yield(get_tree().create_timer(reload_rate), "timeout") 
	$AudioStreamPlayer.stream = load("res://Assets/sounds/reload.wav")
	$AudioStreamPlayer.play()
	current_ammo = clip_size
	HUD.update_ammo(self)
	reloading = false


func deal_damage():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		#print("[Weapon] deal damage to ", collider.name)
		if collider.has_method("take_damage"): # If raycast from the head is colliding with an enemy
			var distance = (raycast.get_collision_point() - raycast.global_transform.origin).length()
			var decayed_damage = range_lerp(distance, 0, max_range, max_damage, min_damage)
			collider.take_damage(decayed_damage) # Enemy takes damage, handled by Healthbar
		if collider.is_in_group("walls"):
			spawn_bullet_hole(raycast.get_collision_point())

func spawn_bullet_hole(collision_point):
	var BulletHole = BULLET_HOLE.instance()
	var scene_root = get_tree().root.get_children()[0]
	BulletHole.global_transform.origin = collision_point
	scene_root.add_child(BulletHole)


func spread():
	raycast.rotation = Vector3(0,0,0)
	raycast.rotate_x(deg2rad(rand_range(-current_spread,current_spread)))
	raycast.rotate_y(deg2rad(rand_range(-current_spread,current_spread)))
	current_spread = lerp(current_spread, max_spread  * scoping_modifier * running_modifier, 1.0/clip_size)
	#print("[Weapon] current_spread ", current_spread)


func scope():
	if Input.is_action_pressed("alt_fire"):
		camera.fov = lerp(camera.fov, scoped_fov, 0.25)
	else:
		camera.fov = lerp(camera.fov, default_fov, 0.25)
	# Without scoping spread, recoil, and walking speed are multiplied by 1, with scoping it's 0.3
	scoping_modifier = range_lerp(camera.fov, default_fov, scoped_fov, 1, 0.2)
