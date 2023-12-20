extends Node

var damage_stats: Dictionary = {
	"Sword": 24007,
	"Hammer": 9822,
	"Anvil": 5660,
	"Dagger": 900,
	"Spear": 15006
}
var enemies_killed = 2245

func record_damage(source: String, damage: float):
	if damage_stats.has(source):
		damage_stats[source] += damage
	else:
		damage_stats[source] = damage

func record_enemy_kill():
	enemies_killed += 1

func reset_stats():
	damage_stats = {}
	enemies_killed = 0
