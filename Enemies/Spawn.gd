extends Position3D

const ENEMY = preload("res://Enemies/Enemy.tscn")

export var active = true
export var max_enemies = 3
export var spawn_frequency = 0.5

var can_spawn = true

func _physics_process(delta):
	if active and can_spawn and $Enemies.get_children().size() < max_enemies:
		spawn_enemy()
		can_spawn = false
		yield(get_tree().create_timer(spawn_frequency), "timeout")
		can_spawn = true
		
	
	
func spawn_enemy():
	var instance = ENEMY.instance()
	var scene_root = get_tree().root.get_children()[0]
	#instance.global_transform.origin = global_transform.origin
	# Set enemy weapon according to the number of crystals collected
	$Enemies.add_child(instance)
