extends Node2D
class_name HammerAbility

@onready var hitbox_component: HitBoxComponent = $HitBoxComponent

func create_out_tween(target_position: Vector2):
	var out_tween = create_tween()
	out_tween.tween_method(move_out.bind(global_position, target_position), 0.0, 1.0, 1)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	out_tween.tween_callback(create_in_tween)

func create_in_tween():
	var in_tween = create_tween()
	in_tween.tween_method(move_in.bind(global_position), 0.0, 1.0, 1)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	in_tween.tween_callback(queue_free)

func move_out(percent: float, start_position: Vector2, target_position: Vector2):
	global_position = start_position.lerp(target_position, percent)
	look_at(target_position)

func move_in(percent: float, start_position: Vector2):
	var player = get_tree().get_first_node_in_group("player") as Node2D
	var target_position = player.global_position + Vector2(0, -8)
	global_position = start_position.lerp(target_position, percent)
	
	var direction_from_start = target_position - start_position
	var target_rotation = direction_from_start.angle()
	rotation = lerp_angle(rotation, target_rotation, 0.1)
