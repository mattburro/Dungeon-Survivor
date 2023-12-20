extends CanvasLayer

@onready var main_panel_container = %MainPanelContainer
@onready var stats_panel_container = $StatsPanelContainer

func _ready():
	get_tree().paused = true
	%ContinueButton.pressed.connect(on_continue_button_pressed)
	%UpgradesButton.pressed.connect(on_upgrades_button_pressed)
	%QuitButton.pressed.connect(on_quit_button_pressed)
	
	main_panel_container.pivot_offset = main_panel_container.size / 2
	var main_panel_in_tween = create_tween()
	main_panel_in_tween.tween_property(main_panel_container, "scale", Vector2.ZERO, 0)
	main_panel_in_tween.tween_property(main_panel_container, "scale", Vector2.ONE, 0.3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	var stats_panel_slide_tween = create_tween()
	stats_panel_slide_tween.tween_property(stats_panel_container, "position", Vector2(23, 25), 0.3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_delay(0.8)
	
	set_stats()

func set_stats():
	var time_elapsed = get_tree().root.get_node("/root/Main/ArenaTimeManager").get_time_elapsed()
	var formatted_time_elapsed = get_tree().root.get_node("/root/Main/ArenaTimeUI").format_seconds_to_string(time_elapsed)
	var level = get_tree().root.get_node("/root/Main/ExperienceManager").current_level
	
	%TimePlayedLabel.text = formatted_time_elapsed
	%EnemiesKilledLabel.text = format_number(StatTracking.enemies_killed)
	%LevelLabel.text = str(level)
	
	for ability in StatTracking.damage_stats:
		var row = HBoxContainer.new()
		var ability_label = Label.new()
		ability_label.theme_type_variation = "BlueOutlineLabel"
		ability_label.text = ability
		row.add_child(ability_label)
		var damage_label = Label.new()
		damage_label.theme_type_variation = "BlueOutlineLabel"
		damage_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		damage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		damage_label.text = format_number(StatTracking.damage_stats[ability])
		row.add_child(damage_label)
		%DamageTable.add_child(row)

func format_number(number):
	var output = str(round(number))
	var i = output.length() - 3
	while i > 0:
		output = output.insert(i, ",")
		i -= 3
	return output

func set_defeat():
	%TitleLabel.text = "DEFEAT"
	%DescriptionLabel.text = "You lost!"
	%VictoryParticles.emitting = false
	play_jingle(true)

func play_jingle(defeat: bool = false):
	if defeat:
		$DefeatStreamPlayer.play()
	else:
		$VictoryStreamPlayer.play()

func on_continue_button_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func on_upgrades_button_pressed():
	ScreenTransition.transition_to_scene("res://scenes/UI/meta_menu.tscn")
	await ScreenTransition.transitioned_halfway
	get_tree().paused = false

func on_quit_button_pressed():
	ScreenTransition.transition_to_scene("res://scenes/UI/main_menu.tscn")
	await ScreenTransition.transitioned_halfway
	get_tree().paused = false
