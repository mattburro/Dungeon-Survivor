extends CanvasLayer

@export var experience_manager: Node

@onready var progress_bar = $MarginContainer/ProgressBar
@onready var level_label = %LevelLabel

func _ready():
	progress_bar.value = 0
	experience_manager.experience_updated.connect(on_experience_updated)
	experience_manager.level_up.connect(on_level_up)

func on_experience_updated(current_experience: float, target_experience: float):
	var percent = current_experience / target_experience
	progress_bar.value = percent

func on_level_up(level):
	level_label.text = "Level " + str(level)
