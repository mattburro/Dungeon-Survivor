extends CharacterBody2D

@onready var visuals = $Visuals
@onready var velocity_component = $VelocityComponent
@onready var health_component = $HealthComponent

const MIN_TELEPORT_DISTANCE = 80

func _ready():
	$HurtBoxComponent.hit.connect(on_hit)
	$TeleportTimer.timeout.connect(on_teleport_timer_timeout)

func _process(delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self, delta)
	
	var move_sign = sign(velocity_component.velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)

func teleport():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	
	if global_position.distance_to(player.global_position) > MIN_TELEPORT_DISTANCE:
		global_position = lerp(global_position, player.global_position, 0.7)

func on_hit():
	$RandomHitAudioPlayerComponent.play_random()

func on_teleport_timer_timeout():
	$AnimationPlayer.play("teleport")
