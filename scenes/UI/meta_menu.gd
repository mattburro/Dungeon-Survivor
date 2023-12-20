extends CanvasLayer

@export var upgrades: Array[MetaUpgrade] = []

@onready var grid_container = %GridContainer

var upgrade_cards = []

var meta_upgrade_card_scene = preload("res://scenes/UI/meta_upgrade_card.tscn")

func _ready():
	%BackButton.pressed.connect(on_back_pressed)
	%ResetButton.pressed.connect(on_reset_pressed)
	for upgrade in upgrades:
		var meta_upgrade_card_instance = meta_upgrade_card_scene.instantiate()
		grid_container.add_child(meta_upgrade_card_instance)
		meta_upgrade_card_instance.set_meta_upgrade(upgrade)
		upgrade_cards.append(meta_upgrade_card_instance)

func on_back_pressed():
	ScreenTransition.transition_to_scene("res://scenes/UI/main_menu.tscn")

func on_reset_pressed():
	MetaProgression.reset_upgrades()
	for card in upgrade_cards:
		card.update_progress()
