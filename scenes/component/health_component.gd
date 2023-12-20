extends Node
class_name HealthComponent

signal died
signal health_decreased

@export var max_health: float = 10.0

var floating_text_scene = preload("res://scenes/UI/floating_text.tscn")

var current_health: float

func _ready():
	current_health = max_health

func take_damage(damage: float, source = null):
	var is_crit = false
	
	if source:
		var crit_chance = MetaProgression.get_upgrade_count("crit_chance") * 0.02
		is_crit = randf() <= crit_chance
		if is_crit:
			damage *= 1.5
	
	var damage_taken = damage if current_health - damage > 0 else current_health
	current_health = max(current_health - damage, 0)
	health_decreased.emit()
	check_death()
	
	if source:
		create_floating_damage_text(damage, is_crit)
		StatTracking.record_damage(source, damage_taken)

func heal(heal_amount: float):
	current_health = min(current_health + heal_amount, max_health)

func get_health_percent():
	if max_health <= 0:
		return 0
	
	return min(current_health / max_health, 1)

func check_death():
	if current_health == 0:
		died.emit()
		
		if owner.is_in_group("enemy"):
			StatTracking.record_enemy_kill()
		
		owner.queue_free()

func create_floating_damage_text(damage, is_crit):
	var floating_text = floating_text_scene.instantiate() as Node2D
	floating_text.global_position = owner.global_position + (Vector2.UP * 16)
	get_tree().get_first_node_in_group("foreground_layer").add_child(floating_text)
	
	var format_string = "%0.1f"
	if round(damage) == damage:
		format_string = "%0.0f"
	floating_text.start(str(format_string % damage), is_crit)
