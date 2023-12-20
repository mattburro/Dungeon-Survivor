extends Node

signal arena_difficulty_increased(arena_difficulty: int)
signal health_regen_tick

const DIFFICULTY_INTERVAL = 5

@export var end_screen_scene: PackedScene

@onready var game_timer = $GameTimer
@onready var health_regen_timer = $HealthRegenTimer

var arena_difficulty = 0

func _ready():
	game_timer.timeout.connect(on_game_timer_timeout)
	health_regen_timer.timeout.connect(on_health_regen_timer_timeout)

func _process(delta):
	var next_time_target = game_timer.wait_time - ((arena_difficulty + 1) * DIFFICULTY_INTERVAL)
	if game_timer.time_left <= next_time_target:
		arena_difficulty += 1
		arena_difficulty_increased.emit(arena_difficulty)

func get_time_elapsed():
	return game_timer.wait_time - game_timer.time_left

func on_game_timer_timeout():
	var victory_screen_instance = end_screen_scene.instantiate()
	add_child(victory_screen_instance)
	victory_screen_instance.play_jingle()
	MetaProgression.save()

func on_health_regen_timer_timeout():
	health_regen_tick.emit()
