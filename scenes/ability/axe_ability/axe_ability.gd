extends Node2D

@onready var hitbox_component: HitBoxComponent = $HitBoxComponent
@onready var sprite = $Sprite2D
@onready var collision_shape = $HitBoxComponent/CollisionShape2D

var base_rotation = Vector2.RIGHT
var rotation_radius = 40
var number_of_rotations = 1
var size = 1.0

func _ready():
	collision_shape.shape.radius *= size
	sprite.scale *= size
	base_rotation = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var tween = create_tween()
	tween.tween_method(tween_rotate, 0.0, 1.0 * number_of_rotations, 1.0 * number_of_rotations)
	tween.tween_callback(queue_free)

func tween_rotate(rotations: float):
	var percent = rotations / (1.0 * number_of_rotations)
	var current_radius = (rotation_radius * number_of_rotations) * percent
	var current_direction = base_rotation.rotated(rotations * TAU)
	
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	global_position = player.global_position + (current_direction * current_radius)
