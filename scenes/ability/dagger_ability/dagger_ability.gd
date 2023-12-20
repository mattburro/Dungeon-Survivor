extends Node2D

@onready var hitbox_component: HitBoxComponent = $HitBoxComponent

const MOVE_SPEED = 200

var direction: Vector2
var enemies_pierced = 0
var enemies_to_pierce = 0

func _ready():
	hitbox_component.area_entered.connect(on_area_entered)
	hitbox_component.body_entered.connect(on_body_entered)

func _process(delta):
	global_position += direction * MOVE_SPEED * delta

func on_area_entered(other_area: Area2D):
	if other_area.owner.is_in_group("enemy"):
		enemies_pierced += 1
		if enemies_pierced > enemies_to_pierce:
			queue_free()

func on_body_entered(other_body: Node2D):
	queue_free()
