extends Control

var pain_effect = 0.0


func update_ammo(weapon):
	$AmmoLabel.set_text("%02d|%02d" % [weapon.current_ammo, weapon.clip_size])

func update_grenade_ammo(ammo):
	$GrenadeLabel.set_text("G"+str(ammo))
	
func update_healthbars(health_node):
	$HealthBar.value = health_node.current_health * 100/health_node.max_health
	$EnergyBar.value = health_node.current_energy * 100/health_node.max_energy

func _physics_process(delta):
	pain_fade(delta)
	
func pain_effect():
	pain_effect = 1.0
	$PainEffect.show()

func pain_fade(delta):
	if pain_effect > 0:
		pain_effect -= delta * 1.5 # gradually fade pain effect
		$PainEffect.modulate.a = pain_effect
		if pain_effect < 0:
			$PainEffect.hide()
