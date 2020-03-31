extends Spatial

export var max_health = 100.0
var current_health


func _ready():
	current_health = max_health

func _physics_process(delta):
	look_at(G.PlayerNode.global_transform.origin + Vector3(0,1.75,0), Vector3.UP)

func take_damage(damage):
	current_health -= damage
	$HealthProgress.scale.x = current_health/max_health
	if current_health <= 0:
		die()
		#spawn_ammo()


func die():
	get_parent().queue_free()

#func spawn_ammo():
#	var instance = AMMO.instance()
#	var scene_root = get_tree().root.get_children()[0]
#	instance.global_transform = parent.global_transform
#	scene_root.add_child(ammo_instance)

