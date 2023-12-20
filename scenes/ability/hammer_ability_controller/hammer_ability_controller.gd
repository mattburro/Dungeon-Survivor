extends Node

@export var hammer_ability_scene: PackedScene

const BASE_DAMAGE = 12
const BASE_DISTANCE = 80

var additional_damage_percent = 1.0
var additional_distance_percent = 1.0
var additional_hammer_count = 0

func _ready():
	$Timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)

func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	
	var adjusted_hammer_count = 1 + additional_hammer_count
	var base_direction = player.last_movement_direction.rotated(deg_to_rad(180))
	var rotation_offset_adjustment = 0
	var rotation_offset_sign = 1
	for i in adjusted_hammer_count:
		var rotation_offset = 0
		if i > 0:
			if i % 2 == 1:
				rotation_offset_adjustment += 15
			else:
				rotation_offset_sign *= -1
			rotation_offset = rotation_offset_adjustment * rotation_offset_sign
		
		var adjusted_direction = base_direction.rotated(deg_to_rad(rotation_offset))
		var target_position = player.global_position + Vector2(0, -8) + (adjusted_direction * (BASE_DISTANCE * additional_distance_percent))
		var hammer_ability_instance = hammer_ability_scene.instantiate() as HammerAbility
		get_tree().get_first_node_in_group("foreground_layer").add_child(hammer_ability_instance)
		hammer_ability_instance.global_position = player.global_position + Vector2(0, -8)
		hammer_ability_instance.hitbox_component.damage = BASE_DAMAGE * (additional_damage_percent + (MetaProgression.get_upgrade_count("damage") * 0.03))
		hammer_ability_instance.hitbox_component.source = "Hammer"
		hammer_ability_instance.create_out_tween(target_position)

func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "hammer_damage":
		additional_damage_percent = 1.0 + (current_upgrades["hammer_damage"]["quantity"] * 0.25)
	elif upgrade.id == "hammer_distance":
		additional_distance_percent = 1.0 + (current_upgrades["hammer_distance"]["quantity"] * 0.25)
	elif upgrade.id == "hammer_count":
		additional_hammer_count = current_upgrades["hammer_count"]["quantity"]
