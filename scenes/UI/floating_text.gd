extends Node2D

@onready var label = $Label

func _ready():
	pass

func start(text: String, is_crit: bool):
	label.text = text
	var scale_amount = 1.2
	
	if is_crit:
		scale_amount = 1.5
		label.add_theme_color_override("font_color", Color.ORANGE_RED)
	
	var tween = create_tween()
	tween.set_parallel()
	
	tween.tween_property(self, "global_position", global_position + (Vector2.UP * 16), 0.5)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2.ONE * scale_amount, 0.5)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.chain()
	
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.chain()
	
	tween.tween_callback(queue_free)
