extends Node

@export var experience_manager: Node
@export var upgrade_screen_scene: PackedScene

var current_upgrades = {}
var upgrade_pool: WeightedTable = WeightedTable.new()

var upgrade_anvil = preload("res://resources/upgrades/anvil.tres")
var upgrade_anvil_count = preload("res://resources/upgrades/anvil_count.tres")
var upgrade_anvil_damage = preload("res://resources/upgrades/anvil_damage.tres")
var upgrade_anvil_size = preload("res://resources/upgrades/anvil_size.tres")
var upgrade_axe = preload("res://resources/upgrades/axe.tres")
var upgrade_axe_damage = preload("res://resources/upgrades/axe_damage.tres")
var upgrade_axe_size = preload("res://resources/upgrades/axe_size.tres")
var upgrade_axe_rotations = preload("res://resources/upgrades/axe_rotations.tres")
var upgrade_sword_rate = preload("res://resources/upgrades/sword_rate.tres")
var upgrade_sword_damage = preload("res://resources/upgrades/sword_damage.tres")
var upgrade_player_speed = preload("res://resources/upgrades/player_speed.tres")
var upgrade_dagger = preload("res://resources/upgrades/dagger.tres")
var upgrade_dagger_count = preload("res://resources/upgrades/dagger_count.tres")
var upgrade_dagger_pierce = preload("res://resources/upgrades/dagger_pierce.tres")
var upgrade_dagger_damage = preload("res://resources/upgrades/dagger_damage.tres")
var upgrade_hammer = preload("res://resources/upgrades/hammer.tres")
var upgrade_hammer_damage = preload("res://resources/upgrades/hammer_damage.tres")
var upgrade_hammer_distance = preload("res://resources/upgrades/hammer_distance.tres")
var upgrade_hammer_count = preload("res://resources/upgrades/hammer_count.tres")
var upgrade_spear = preload("res://resources/upgrades/spear.tres")
var upgrade_spear_bounces = preload("res://resources/upgrades/spear_bounces.tres")
var upgrade_spear_rate = preload("res://resources/upgrades/spear_rate.tres")
var upgrade_spear_damage = preload("res://resources/upgrades/spear_damage.tres")

func _ready():
	upgrade_pool.add_item(upgrade_sword_damage, 10)
	upgrade_pool.add_item(upgrade_sword_rate, 8)
	upgrade_pool.add_item(upgrade_axe, 6)
	upgrade_pool.add_item(upgrade_hammer, 6)
	upgrade_pool.add_item(upgrade_anvil, 6)
	upgrade_pool.add_item(upgrade_spear, 6)
	upgrade_pool.add_item(upgrade_dagger, 6)
	upgrade_pool.add_item(upgrade_player_speed, 4)
	experience_manager.level_up.connect(on_level_up)

func apply_upgrade(upgrade: AbilityUpgrade):
	var has_upgrade = current_upgrades.has(upgrade.id)
	if !has_upgrade:
		current_upgrades[upgrade.id] = {
			"resource": upgrade,
			"quantity": 1
		}
	else:
		current_upgrades[upgrade.id]["quantity"] += 1
	
	if upgrade.max_quantity > 0:
		var current_quantity = current_upgrades[upgrade.id]["quantity"]
		if current_quantity == upgrade.max_quantity:
			upgrade_pool.remove_item(upgrade)
	
	update_upgrade_pool(upgrade)
	GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades)

func update_upgrade_pool(chosen_upgrade: AbilityUpgrade):
	if chosen_upgrade.id == upgrade_axe.id:
		upgrade_pool.add_item(upgrade_axe_damage, 8)
		upgrade_pool.add_item(upgrade_axe_size, 6)
		upgrade_pool.add_item(upgrade_axe_rotations, 4)
	elif chosen_upgrade.id == upgrade_hammer.id:
		upgrade_pool.add_item(upgrade_hammer_damage, 8)
		upgrade_pool.add_item(upgrade_hammer_distance, 5)
		upgrade_pool.add_item(upgrade_hammer_count, 3)
	elif chosen_upgrade.id == upgrade_anvil.id:
		upgrade_pool.add_item(upgrade_anvil_count, 3)
		upgrade_pool.add_item(upgrade_anvil_damage, 8)
		upgrade_pool.add_item(upgrade_anvil_size, 6)
	elif chosen_upgrade.id == upgrade_dagger.id:
		upgrade_pool.add_item(upgrade_dagger_count, 5)
		upgrade_pool.add_item(upgrade_dagger_pierce, 6)
		upgrade_pool.add_item(upgrade_dagger_damage, 8)
	elif chosen_upgrade.id == upgrade_spear.id:
		upgrade_pool.add_item(upgrade_spear_bounces, 4)
		upgrade_pool.add_item(upgrade_spear_rate, 6)
		upgrade_pool.add_item(upgrade_spear_damage, 8)

func pick_upgrades():
	var chosen_upgrades: Array[AbilityUpgrade] = []
	var number_of_upgrades = 2 + MetaProgression.get_upgrade_count("additional_upgrade")
	for i in number_of_upgrades:
		if upgrade_pool.items.size() == chosen_upgrades.size():
			break
		
		var chosen_upgrade = upgrade_pool.pick_item(chosen_upgrades)
		chosen_upgrades.append(chosen_upgrade)
	
	return chosen_upgrades

func on_upgrade_selected(upgrade: AbilityUpgrade):
	apply_upgrade(upgrade)

func on_level_up(current_level: int):
	var upgrade_screen_instance = upgrade_screen_scene.instantiate()
	add_child(upgrade_screen_instance)
	var chosen_upgrades = pick_upgrades()
	if chosen_upgrades.size() > 0:
		upgrade_screen_instance.set_ability_upgrades(chosen_upgrades, current_upgrades)
		upgrade_screen_instance.upgrade_selected.connect(on_upgrade_selected)
