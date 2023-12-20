extends Area2D

@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer

const MOVE_SPEED = 160

var velocity: Vector2

func _ready():
	timer.timeout.connect(on_timer_timeout)

func _process(delta):
	global_position += velocity * delta

func move_toward_player():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	velocity = (player.global_position - global_position).normalized() * MOVE_SPEED

func explode():
	animation_player.play("explode")

func on_timer_timeout():
	explode()
