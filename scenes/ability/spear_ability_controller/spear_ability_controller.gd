extends Node

@export var spear_ability_scene: PackedScene

const THROW_RANGE = 180
const BOUNCE_RANGE = 80

var base_bounces = 4
var additional_bounces = 0
var base_damage = 8
var additional_damage_percent = 1.0
var base_wait_time

func _ready():
	base_wait_time = $Timer.wait_time
	$Timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)

func get_closest_enemy_within_range(enemies, enemiesToIgnore, origin: Vector2, range: float):
	enemies = enemies.filter(func (enemy: Node2D):
		return origin.distance_to(enemy.global_position) < range
	)
	for enemy in enemiesToIgnore:
		if enemies.has(enemy):
			enemies.erase(enemy)
	
	if enemies.size() == 0:
		return null
	
	enemies.sort_custom(func (a: Node2D, b: Node2D):
		var a_distance = origin.distance_to(a.global_position)
		var b_distance = origin.distance_to(b.global_position)
		return a_distance < b_distance
	)
	
	return enemies[0]

func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	var max_bounces = base_bounces + additional_bounces
	
	var enemies = []
	var all_enemies = get_tree().get_nodes_in_group("enemy")
	for i in max_bounces:
		var next_enemy: Node2D
		if i == 0:
			next_enemy = get_closest_enemy_within_range(all_enemies, enemies, player.global_position, THROW_RANGE)
		else:
			next_enemy = get_closest_enemy_within_range(all_enemies, enemies, enemies[i - 1].global_position, BOUNCE_RANGE)
		
		if next_enemy != null:
			enemies.append(next_enemy)
		else:
			break
	
	if enemies.size() > 0:
		var spear_ability_instance = spear_ability_scene.instantiate() as SpearAbility
		get_tree().get_first_node_in_group("foreground_layer").add_child(spear_ability_instance)
		spear_ability_instance.global_position = player.global_position + Vector2(0, -8)
		spear_ability_instance.hitbox_component.damage = base_damage * (additional_damage_percent + (MetaProgression.get_upgrade_count("damage") * 0.03))
		spear_ability_instance.hitbox_component.source = "Spear"
		spear_ability_instance.current_enemy = enemies[0]
		spear_ability_instance.enemies = enemies

func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "spear_rate":
		var percent_reduction = current_upgrades["spear_rate"]["quantity"] * 0.1
		$Timer.wait_time = base_wait_time * (1.0 - percent_reduction)
		$Timer.start()
	elif upgrade.id == "spear_bounces":
		additional_bounces = current_upgrades["spear_bounces"]["quantity"] * 2
	elif upgrade.id == "spear_damage":
		additional_damage_percent = 1.0 + (current_upgrades["spear_damage"]["quantity"] * 0.25)
