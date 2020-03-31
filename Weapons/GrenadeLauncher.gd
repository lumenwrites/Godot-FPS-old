extends Position3D


const GRENADE = preload("res://Weapons/Grenade.tscn")
onready var HUD = get_node("/root/World/HUD")
export var grenade_speed = 15
export var fire_rate = 3.0
var can_fire = true

func _physics_process(delta):
	if Input.is_action_just_pressed("grenade") and can_fire:
		throw_grenade()
		
		
func throw_grenade():
	var instance = GRENADE.instance()
	var scene_root = get_tree().root.get_children()[0]
	instance.global_transform.origin = global_transform.origin
	instance.linear_velocity = -global_transform.basis.z * grenade_speed
	scene_root.add_child(instance)	

	HUD.update_grenade_ammo(0)
	can_fire = false
	yield(get_tree().create_timer(fire_rate), "timeout") # wait until timer times out
	can_fire = true
	HUD.update_grenade_ammo(1)
