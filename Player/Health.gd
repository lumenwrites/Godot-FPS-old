extends Node


export (int) var max_health = 100
var current_health 
export (int) var max_energy = 100
var current_energy

onready var HUD = get_tree().get_root().get_node("World/HUD")

func _ready():
	current_health = max_health
	current_energy = max_energy
	HUD.update_healthbars(self)
	
func _physics_process(delta):
	charge(10*delta)

func take_damage(amount):
	HUD.pain_effect()
	if current_health > 0:
		current_health -= amount
		HUD.update_healthbars(self)
		if current_health <= 0:
			G.restart()

func heal(amount):
	if current_health < 100:
		current_health += amount
		current_health = int(clamp(current_health, 0, max_health))
		HUD.update_healthbars(self)
		
func discharge(amount):
	if current_energy > 0:
		current_energy -= amount
		HUD.update_healthbars(self)

func charge(amount):
	if current_energy < 100:
		current_energy += amount
		current_energy = clamp(current_energy, 0, max_energy)
		HUD.update_healthbars(self)
