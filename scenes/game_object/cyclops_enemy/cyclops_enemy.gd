extends CharacterBody2D

@export var rock_scene: PackedScene

@onready var visuals = $Visuals
@onready var velocity_component = $VelocityComponent
@onready var health_component = $HealthComponent
@onready var rock_throw_timer = %RockThrowTimer
@onready var rock_throw_area_2d = %RockThrowArea2D

func _ready():
	$HurtBoxComponent.hit.connect(on_hit)
	%RockThrowArea2D.body_entered.connect(on_rock_throw_area_body_entered)

func _process(delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self, delta)
	
	var move_sign = sign(velocity_component.velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(-move_sign, 1)

func spawn_rock():
	if !rock_throw_timer.is_stopped():
		return
	
	rock_throw_timer.start()
	var rock_instance = rock_scene.instantiate() as Node2D
	get_tree().get_first_node_in_group("foreground_layer").add_child(rock_instance)
	rock_instance.global_position = global_position
	rock_instance.move_toward_player()

func on_hit():
	$RandomHitAudioPlayerComponent.play_random()

func on_rock_throw_area_body_entered(other_body: Node2D):
	if other_body.is_in_group("player"):
		call_deferred("spawn_rock")
