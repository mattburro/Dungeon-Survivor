extends Node2D
class_name SpearAbility

@onready var hitbox_component: HitBoxComponent = $HitBoxComponent

const MOVE_SPEED = 220

var current_enemy
var current_enemy_index = 0
var enemies = []

func _ready():
	hitbox_component.area_entered.connect(on_hitbox_area_entered)

func _process(delta):
	if current_enemy != null:
		look_at(current_enemy.global_position)
		var direction = (current_enemy.global_position - global_position).normalized()
		global_position += direction * MOVE_SPEED * delta
	else:
		get_next_enemy()

func get_next_enemy():
	current_enemy_index += 1
	if current_enemy_index < enemies.size():
		current_enemy = enemies[current_enemy_index]
	else:
		queue_free()

func on_hitbox_area_entered(other_area: Area2D):
	if other_area.owner.is_in_group("enemy"):
		get_next_enemy()
