extends Node

@export var dagger_ability_scene: PackedScene

const SPAWN_RANGE = 15
const SPAWN_OFFSET = Vector2.UP * 8

var base_damage = 25
var additional_damage_percent = 1.0
var dagger_count = 4
var enemies_to_pierce = 0

func _ready():
	GameEvents.player_damaged.connect(shoot_daggers)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)

func shoot_daggers():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	var rotation_degrees = 360.0 / dagger_count
	for i in dagger_count:
		var direction = Vector2.UP.rotated(deg_to_rad(i * rotation_degrees)).normalized()
		var spawn_position = player.global_position + SPAWN_OFFSET + (direction * SPAWN_RANGE)
		Callable(spawn_dagger.bind(spawn_position, direction)).call_deferred()

func spawn_dagger(position, direction):
	var dagger_ability_instance = dagger_ability_scene.instantiate() as Node2D
	dagger_ability_instance.global_position = position
	dagger_ability_instance.direction = direction
	dagger_ability_instance.rotation = direction.angle()
	dagger_ability_instance.enemies_to_pierce = enemies_to_pierce
	get_tree().get_first_node_in_group("foreground_layer").add_child(dagger_ability_instance)
	dagger_ability_instance.hitbox_component.damage = base_damage * (additional_damage_percent + (MetaProgression.get_upgrade_count("damage") * 0.03))
	dagger_ability_instance.hitbox_component.source = "Dagger"

func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "dagger_count":
		dagger_count = (current_upgrades["dagger_count"]["quantity"] + 1) * 4
	elif upgrade.id == "dagger_pierce":
		enemies_to_pierce = current_upgrades["dagger_pierce"]["quantity"]
	elif upgrade.id == "dagger_damage":
		additional_damage_percent = 1.0 + (current_upgrades["dagger_damage"]["quantity"] * 0.2)
