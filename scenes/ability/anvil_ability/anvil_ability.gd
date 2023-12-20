extends Node2D

@onready var hitbox_component = $HitBoxComponent
@onready var collision_shape = $HitBoxComponent/CollisionShape2D
@onready var visuals = $Visuals

var size = 1.0

func _ready():
	visuals.scale *= size
	collision_shape.shape.radius *= size
