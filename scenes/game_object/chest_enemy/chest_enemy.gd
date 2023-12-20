extends CharacterBody2D

@onready var visuals = $Visuals
@onready var velocity_component = $VelocityComponent
@onready var health_component = $HealthComponent

var is_moving = false

func _ready():
	$HurtBoxComponent.hit.connect(on_hit)

func _process(delta):
	if is_moving:
		velocity_component.accelerate_to_player()
		velocity_component.move(self, delta)
	
	var move_sign = sign(velocity_component.velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)

func set_is_moving(value: bool):
	is_moving = value

func on_hit():
	$RandomHitAudioPlayerComponent.play_random()
