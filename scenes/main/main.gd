extends Node

@export var end_screen_scene: PackedScene

var pause_menu_scene = preload("res://scenes/UI/pause_menu.tscn")

func _ready():
	$%Player.health_component.died.connect(on_player_died)
	$EnemyKillArea2D.body_entered.connect(on_enemy_kill_area_body_entered)
	StatTracking.reset_stats()

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		add_child(pause_menu_scene.instantiate())
		get_tree().root.set_input_as_handled()

func on_player_died():
	var end_screen_instance = end_screen_scene.instantiate()
	add_child(end_screen_instance)
	end_screen_instance.set_defeat()
	MetaProgression.save()

func on_enemy_kill_area_body_entered(other_body: Node2D):
	if other_body.is_in_group("enemy"):
		other_body.queue_free()
