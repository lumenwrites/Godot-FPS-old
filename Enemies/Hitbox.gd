extends Area

export var damage_multiplier = 1.0


func take_damage(damage):
	#print("Hitbox got shot ", name)
	#print("Received damage ", damage)
	owner.get_node("Healthbar").take_damage(damage*damage_multiplier)
