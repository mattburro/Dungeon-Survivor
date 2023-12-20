extends Node2D

@export var sword_ability_scene: PackedScene

const MAX_RANGE = 90

var base_damage = 5.0
var additional_damage_percent = 1.0
var base_wait_time

func _ready():
	base_wait_time = $Timer.wait_time
	$Timer.timeout.connect(on_timer_timeout)
	$TargetArea2D/CollisionShape2D.shape.radius = MAX_RANGE
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)

func _process(delta):
	pass

func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	
	var enemies: Array[Area2D] = $TargetArea2D.get_overlapping_areas()
	enemies = enemies.filter(func (area):
		return area.owner.is_in_group("enemy")
	)
	
	if enemies.size() == 0:
		return
	
	enemies.sort_custom(func (a: Area2D, b: Area2D):
		var a_distance = a.global_position.distance_to(player.global_position)
		var b_distance = b.global_position.distance_to(player.global_position)
		return a_distance < b_distance
	)
	
	var sword_ability_instance = sword_ability_scene.instantiate() as SwordAbility
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
	foreground_layer.add_child(sword_ability_instance)
	var sword_damage = base_damage * (additional_damage_percent + (MetaProgression.get_upgrade_count("damage") * 0.03))
	sword_ability_instance.hitbox_component.damage = sword_damage
	sword_ability_instance.hitbox_component.source = "Sword"
	sword_ability_instance.global_position = enemies[0].global_position
	sword_ability_instance.global_position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * 4
	
	var enemy_direction = enemies[0].global_position - sword_ability_instance.global_position
	sword_ability_instance.rotation = enemy_direction.angle()

func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "sword_rate":
		var percent_reduction = current_upgrades["sword_rate"]["quantity"] * 0.1
		$Timer.wait_time = base_wait_time * (1.0 - percent_reduction)
		$Timer.start()
	elif upgrade.id == "sword_damage":
		additional_damage_percent = 1.0 + (current_upgrades["sword_damage"]["quantity"] * 0.5)
