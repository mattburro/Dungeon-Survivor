extends Node

@export var axe_ability_scene: PackedScene

const BASE_DAMAGE = 10
const BASE_ROTATIONS = 1.5

var additional_damage_percent = 1.0
var size_percent = 1.0
var additional_rotations = 0

func _ready():
	$Timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)

func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	var axe_ability_instance = axe_ability_scene.instantiate() as Node2D
	axe_ability_instance.global_position = player.global_position
	axe_ability_instance.number_of_rotations = BASE_ROTATIONS + additional_rotations
	axe_ability_instance.size = size_percent
	get_tree().get_first_node_in_group("foreground_layer").add_child(axe_ability_instance)
	axe_ability_instance.hitbox_component.damage = BASE_DAMAGE * (additional_damage_percent + (MetaProgression.get_upgrade_count("damage") * 0.03))
	axe_ability_instance.hitbox_component.source = "Axe"

func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "axe_damage":
		additional_damage_percent = 1.0 + (current_upgrades["axe_damage"]["quantity"] * 0.2)
	elif upgrade.id == "axe_size":
		size_percent = 1.0 + (current_upgrades["axe_size"]["quantity"] * 0.25)
	elif upgrade.id == "axe_rotations":
		additional_rotations = current_upgrades["axe_rotations"]["quantity"] * 0.5
