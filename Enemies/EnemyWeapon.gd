extends Spatial


export var max_damage = 5.0
export var min_damage = 2.0
export var max_range = 15.0

export var aiming_pause = 1.0 # reaction time between when he sees player and when he attacks

export var clip_size = 15
var current_ammo = 0
export var fire_rate = 0.12
export var reload_rate = 1.0

export var spread = 15.0
# Spread adds randomness before each shot so enemy missess sometimes
# Every shot spread decreases, so it gradually becomes more accurate
export var spread_decrease = 0.9
var current_spread = 0

var can_fire = true
var reloading = false
var saw_player = 0.0 # how long ago have I noticed player

onready var raycast = $WeaponRayCast
onready var PlayerLookat = owner.get_node("PlayerLookAt")
onready var EnemyNode = get_parent()

# Functions overridable by children, added on top of what Im already running
func physics_process(delta): return

func _ready():
	current_ammo = clip_size
	current_spread = spread
	raycast.cast_to = Vector3(0,0, -max_range)


func _physics_process(delta):
	slowly_aim_at_player(delta)
	attack(delta)

func slowly_aim_at_player(delta): #(vertically)
	var target_rotation = EnemyNode.PlayerLookAt.rotation
	rotation.x = lerp_angle(rotation.x, target_rotation.x, EnemyNode.aiming_speed*delta)

func attack(delta):
	var distance_to_player = (global_transform.origin - G.PlayerNode.global_transform.origin).length()
	
	# If player has disappeared out of sight, when he reappears it'll take awhile to aim again.
	if not EnemyNode.can_see_player:
		saw_player = 0
		current_spread = spread # Spread decreases every shot, reset it once player is out of sight
	
	# Timer counts how long ago I saw player, so I can start firing only after delay
	if EnemyNode.can_see_player and distance_to_player <= max_range:
		saw_player += delta

	if EnemyNode.can_see_player and distance_to_player <= max_range and saw_player > aiming_pause:
		if can_fire and not reloading:
			if current_ammo > 0: 
				fire()
			else: 
				reload()

		
func fire():
	spread()
	deal_damage()
	current_ammo -= 1
	
	$AudioStreamPlayer3D.stream = load("res://Assets/sounds/gunshot.wav")
	$AudioStreamPlayer3D.play()
	
	can_fire = false
	yield(get_tree().create_timer(fire_rate), "timeout")
	can_fire = true

	
func deal_damage():
	if raycast.is_colliding():
		# print("[EnemyWeapon] deal damage to ", raycast.get_collider().name)
		var collider = raycast.get_collider()
		if collider is Player:
			var distance = (raycast.get_collision_point() - raycast.global_transform.origin).length()
			var decayed_damage = range_lerp(distance, 0, max_range, max_damage, min_damage)
			collider.take_damage(decayed_damage)


func spread():
	raycast.rotation = Vector3(0,0,0) # Reset rotation messed up by previous spread
	raycast.rotate_x(deg2rad(rand_range(-current_spread,current_spread)))
	raycast.rotate_y(deg2rad(rand_range(-current_spread,current_spread)))
	current_spread *= spread_decrease


func reload():
	$AudioStreamPlayer3D.stream = load("res://Assets/sounds/reload.wav")
	$AudioStreamPlayer3D.play()
	
	reloading = true
	yield(get_tree().create_timer(reload_rate), "timeout") 
	current_ammo = clip_size
	reloading = false
	
	
	
