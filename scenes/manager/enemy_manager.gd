extends Node

const SPAWN_RADIUS = 375
const BURST_CHANCE = 0.01

@export var arena_time_manager: Node
@export var basic_enemy_scene: PackedScene
@export var wizard_enemy_scene: PackedScene
@export var wizard_enemy_2_scene: PackedScene
@export var bat_enemy_scene: PackedScene
@export var crab_enemy_scene: PackedScene
@export var ghost_enemy_scene: PackedScene
@export var spider_enemy_scene: PackedScene
@export var cyclops_enemy_scene: PackedScene
@export var chest_enemy_scene: PackedScene

@onready var timer = $Timer

const MAX_ENEMIES = 400

var base_spawn_time = 0
var enemy_table = WeightedTable.new()
var spawn_amount = 1
var enemies_spawned = 0

func _ready():
	enemy_table.add_item(basic_enemy_scene, 10)
	base_spawn_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)

func get_spawn_position():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return Vector2.ZERO
	
	var spawn_position = Vector2.ZERO
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	for i in 4:
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
		var additional_check_offset = random_direction * 20
		
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position + additional_check_offset, 1)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
	
		if result.is_empty():
			break
		else:
			random_direction = random_direction.rotated(deg_to_rad(90))
	
	return spawn_position

func on_timer_timeout():
	timer.start()
	
	var number_of_enemies = enemies_spawned - StatTracking.enemies_killed
	if number_of_enemies >= MAX_ENEMIES:
		return
	
	var original_spawn_amount = spawn_amount
	if randf() < BURST_CHANCE:
		spawn_amount = randi_range(30, 50)
	
	for i in spawn_amount:
		var enemy_scene = enemy_table.pick_item()
		var enemy = enemy_scene.instantiate() as Node2D
		var entities_layer = get_tree().get_first_node_in_group("entities_layer")
		entities_layer.add_child(enemy)
		enemy.global_position = get_spawn_position()
		enemies_spawned += 1
	
	spawn_amount = original_spawn_amount

func on_arena_difficulty_increased(difficulty: int):
	var time_off = (0.1 / 12) * difficulty
	time_off = min(time_off, 1.4)
	timer.wait_time = base_spawn_time - time_off
	
	# Every 6 difficulty is 30 seconds
	# 1m
	if difficulty == 12:
		enemy_table.add_item(crab_enemy_scene, 8)
	# 2m
	elif difficulty == 24:
		enemy_table.add_item(crab_enemy_scene, 4) # 12
		enemy_table.add_item(wizard_enemy_scene, 5)
		#spawn_amount += 1
	# 3m
	elif difficulty == 36:
		enemy_table.add_item(crab_enemy_scene, 8) # 20
		enemy_table.add_item(wizard_enemy_scene, 10) # 15
		enemy_table.add_item(ghost_enemy_scene, 5)
	# 4m
	elif difficulty == 48:
		enemy_table.add_item(crab_enemy_scene, 5) # 25
		enemy_table.add_item(wizard_enemy_scene, 15) # 30
		enemy_table.add_item(ghost_enemy_scene, 10) # 15
		enemy_table.add_item(bat_enemy_scene, 15)
	# 5m
	elif difficulty == 60:
		enemy_table.add_item(wizard_enemy_scene, 10) # 40
		enemy_table.add_item(ghost_enemy_scene, 15) # 30
		enemy_table.add_item(bat_enemy_scene, 30) # 45
		enemy_table.add_item(spider_enemy_scene, 20)
	# 6m
	elif difficulty == 72:
		enemy_table.add_item(ghost_enemy_scene, 20) # 40
		enemy_table.add_item(bat_enemy_scene, 25) # 70
		enemy_table.add_item(spider_enemy_scene, 20) #40
		enemy_table.add_item(wizard_enemy_2_scene, 30)
		#spawn_amount += 1
	# 7m
	elif difficulty == 84:
		enemy_table.add_item(bat_enemy_scene, 20) # 90
		enemy_table.add_item(spider_enemy_scene, 10) # 50
		enemy_table.add_item(wizard_enemy_2_scene, 20) # 50
		enemy_table.add_item(chest_enemy_scene, 40)
	# 8m
	elif difficulty == 96:
		enemy_table.add_item(spider_enemy_scene, 10) # 60
		enemy_table.add_item(wizard_enemy_2_scene, 30) # 80
		enemy_table.add_item(chest_enemy_scene, 40) # 80
	# 9m
	elif difficulty == 108:
		enemy_table.add_item(wizard_enemy_2_scene, 20) # 100
		enemy_table.add_item(chest_enemy_scene, 20) # 100
		#spawn_amount += 1
	# 10m
	elif difficulty == 120:
		enemy_table.add_item(spider_enemy_scene, 20) # 80
		enemy_table.add_item(chest_enemy_scene, 10) # 110
		enemy_table.add_item(cyclops_enemy_scene, 30)
	# 11m
	elif difficulty == 132:
		enemy_table.add_item(bat_enemy_scene, 20) # 100
		enemy_table.add_item(spider_enemy_scene, 10) # 90
		enemy_table.add_item(cyclops_enemy_scene, 40) # 70
	# 12m
	elif difficulty == 144:
		enemy_table.add_item(cyclops_enemy_scene, 20) # 90
	# 13m
	elif difficulty == 156:
		#spawn_amount += 1
		pass
	# 14m
	elif difficulty == 168:
		#spawn_amount += 1
		pass
