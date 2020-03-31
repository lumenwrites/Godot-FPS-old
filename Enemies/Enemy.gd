extends KinematicBody


export var speed = 4
export var aiming_speed = 3
export var target_distance = 7 # get this close to the player
export var friction = 0.95
export var gravity = 80

onready var Nav = get_node("/root/World/Navigation")
onready var PlayerLookAt = $PlayerLookAt
onready var player_pos = G.PlayerNode.global_transform.origin

var can_see_player = false # also used in weapon
var vel = Vector3()
var target = Vector3() # target for nav path, will be set to player's position
var path = []

func _ready():
	PlayerLookAt.set_as_toplevel(true)

func _physics_process(delta):
	player_pos = G.PlayerNode.global_transform.origin # for convenience to have a shorter variable
	# PlayerLookAt is parented to the world. Move it along with the enemy, point it at player's head.
	PlayerLookAt.global_transform.origin = global_transform.origin + Vector3(0,1.25,0)
	PlayerLookAt.look_at(player_pos + Vector3(0,1.72,0), Vector3.UP)
	# Slowly aim at player
	rotation.y = lerp_angle(rotation.y, PlayerLookAt.rotation.y, aiming_speed*delta)
	
	can_see_player = can_see_player()
	var distance_to_player = global_transform.origin.distance_to(player_pos)
	if distance_to_player > target_distance or not can_see_player: 
		move_towards_player(delta)


func can_see_player():	
	var can_see_player = false
	if PlayerLookAt.is_colliding():
		if PlayerLookAt.get_collider() is Player:
			can_see_player = true
	return can_see_player
	
func move_towards_player(delta):
	update_path()
	follow_path()
	vel *= friction
	vel.y -= gravity * delta
	move_and_slide(vel, Vector3.UP, true)


func update_path():
	# Update NavPath if player walks too far away from the target
	if (target - player_pos).length() > 1: 
		target = player_pos # save into a variable so I know how far player walks away from it
		path = Nav.get_simple_path(global_transform.origin, target)


func follow_path():
	if path.size() > 0: # if we're not at the end of the path
		# Take the first point out of the path(and remove it)
		# Vector between my current position, and the point on the path I need to walk towards
		var direction_to_next_node = path[0] - global_transform.origin

		if direction_to_next_node.length() > 1:
			# Move towards the next point 
			# Only along x/z, let the gravity/collisions handle y
			vel.x = direction_to_next_node.normalized().x * speed
			vel.z = direction_to_next_node.normalized().z * speed
		else:
			# If I have arrived at a point - remove it
			path.remove(0)

func take_damage(damage):
	# Bullet damage applies to hitboxes
	# But for a grenade it's easier to check for overlapping bodies that have take_damage method
	$Healthbar.take_damage(damage)
