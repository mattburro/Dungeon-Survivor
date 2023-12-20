extends PanelContainer

@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var progress_bar = %ProgressBar
@onready var purchase_button = %PurchaseButton
@onready var progress_label = %ProgressLabel
@onready var quantity_label = %QuantityLabel

var upgrade: MetaUpgrade

func _ready():
	purchase_button.pressed.connect(on_purchase_pressed)

func set_meta_upgrade(meta_upgrade: MetaUpgrade):
	upgrade = meta_upgrade
	name_label.text = upgrade.title
	description_label.text = upgrade.description
	update_progress()

func update_progress():
	var currency = MetaProgression.save_data["meta_upgrade_currency"]
	var upgrade_quantity = 0
	if MetaProgression.save_data["meta_upgrades"].has(upgrade.id):
		upgrade_quantity = MetaProgression.save_data["meta_upgrades"][upgrade.id]["quantity"]
	var percent = currency / upgrade.experience_cost
	percent = min(percent, 1.0)
	
	if upgrade_quantity >= upgrade.max_quantity:
		purchase_button.text = "MAX"
		percent = 1.0
		currency = upgrade.experience_cost
	
	purchase_button.disabled = percent < 1.0 || upgrade_quantity >= upgrade.max_quantity
	progress_bar.value = percent
	progress_label.text = str(currency) + "/" + str(upgrade.experience_cost)
	quantity_label.text = "%d/%d" % [upgrade_quantity, upgrade.max_quantity]

func on_purchase_pressed():
	if upgrade == null:
		return
	
	MetaProgression.add_meta_upgrade(upgrade)
	get_tree().call_group("meta_upgrade_card", "update_progress")
	$AnimationPlayer.play("selected")
