extends CanvasLayer

signal upgrade_selected(upgrade: AbilityUpgrade)

@export var upgrade_card_scene: PackedScene

@onready var card_container = $%CardContainer

func _ready():
	get_tree().paused = true

func set_ability_upgrades(upgrades_to_show: Array[AbilityUpgrade], current_upgrades: Dictionary):
	var delay = 0
	for upgrade in upgrades_to_show:
		var card_instance = upgrade_card_scene.instantiate() 
		card_container.add_child(card_instance)
		card_instance.play_in(delay)
		card_instance.set_ability_upgrade(upgrade, current_upgrades)
		card_instance.selected.connect(on_upgrade_selected.bind(upgrade))
		delay += 0.2

func on_upgrade_selected(upgrade: AbilityUpgrade):
	upgrade_selected.emit(upgrade)
	$AnimationPlayer.play("out")
	await $AnimationPlayer.animation_finished
	get_tree().paused = false
	queue_free()
