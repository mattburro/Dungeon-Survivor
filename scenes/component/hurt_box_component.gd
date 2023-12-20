extends Area2D
class_name HurtBoxComponent

signal hit

@export var health_component: HealthComponent

func _ready():
	area_entered.connect(on_area_entered)

func on_area_entered(other_area: Area2D):
	if not other_area is HitBoxComponent:
		return
	
	if health_component == null:
		return
	
	hit.emit()
	var hitbox_component = other_area as HitBoxComponent
	var damage = hitbox_component.damage
	health_component.take_damage(damage, hitbox_component.source)
