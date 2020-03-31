extends RigidBody

export var max_damage = 120
export var min_damage = 80
export var max_range = 5.0
export var explosion_delay = 2.0
var exploded = false

func _ready():
	$DamageArea.scale *= max_range
	yield(get_tree().create_timer(explosion_delay), "timeout")
	explode()

func _input(event):
	if Input.is_action_just_pressed("grenade"):
		explode()

func explode():
	if exploded: return
	exploded = true
	var bodies_within_range = $DamageArea.get_overlapping_bodies()
	for body in bodies_within_range:
		if body.has_method("take_damage"):
			var distance = (body.global_transform.origin - global_transform.origin).length()
			var decayed_damage = range_lerp(distance, 0, max_range, max_damage, min_damage)
			body.take_damage(decayed_damage)
	hide()
	$AudioStreamPlayer3D.stream = load("res://Assets/sounds/explosion.wav")
	$AudioStreamPlayer3D.play()


func _on_AudioStreamPlayer3D_finished():
	queue_free()
