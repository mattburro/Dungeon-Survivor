extends Node2D

@export var spiderweb_scene: PackedScene

@onready var timer = $Timer

func _ready():
	$Area2D.body_entered.connect(on_body_entered)

func spawn_spiderweb():
	if !timer.is_stopped():
		return
	
	timer.start()
	var spiderweb_instance = spiderweb_scene.instantiate() as Node2D
	get_tree().get_first_node_in_group("foreground_layer").add_child(spiderweb_instance)
	spiderweb_instance.global_position = global_position
	spiderweb_instance.move_toward_player()

func on_body_entered(other_body: Node2D):
	if other_body.is_in_group("player"):
		call_deferred("spawn_spiderweb")
