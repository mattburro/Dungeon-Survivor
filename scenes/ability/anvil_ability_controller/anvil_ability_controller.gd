extends Node2D

@export var anvil_ability_scene: PackedScene

var base_damage = 20
var additional_damage_percent = 1.0
var anvil_count = 0
var size_percent = 1.0

func _ready():
	$Timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)

func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	
	var adjusted_anvil_count = anvil_count + 1
	var enemies_hit: Array[Area2D] = []
	var enemies_in_range: Array[Area2D] = $Area2D.get_overlapping_areas()
	if enemies_in_range.size() == 0:
		return
	
	for i in adjusted_anvil_count:
		for enemy in enemies_hit:
			if enemy != null:
				enemies_in_range.erase(enemy)
		
		if enemies_in_range.size() == 0:
			return
		
		var enemy_to_hit = null
		var max_checks = enemies_in_range.size()
		var checks = 0
		while !enemy_to_hit:
			if checks == max_checks:
				return
			
			enemy_to_hit = enemies_in_range.pick_random()
			checks += 1
		
		enemies_hit.append(enemy_to_hit)
		var spawn_position = enemy_to_hit.global_position
		var anvil_ability_instance = anvil_ability_scene.instantiate() as Node2D
		anvil_ability_instance.global_position = spawn_position
		anvil_ability_instance.size = size_percent
		get_tree().get_first_node_in_group("foreground_layer").add_child(anvil_ability_instance)
		anvil_ability_instance.hitbox_component.damage = base_damage * (additional_damage_percent + (MetaProgression.get_upgrade_count("damage") * 0.03))
		anvil_ability_instance.hitbox_component.source = "Anvil"
		await get_tree().create_timer(0.2).timeout

func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "anvil_count":
		anvil_count = current_upgrades["anvil_count"]["quantity"]
	elif upgrade.id == "anvil_damage":
		additional_damage_percent = 1.0 + (current_upgrades["anvil_damage"]["quantity"] * 0.25)
	elif upgrade.id == "anvil_size":
		size_percent = 1.0 + (current_upgrades["anvil_size"]["quantity"] * 0.25)
