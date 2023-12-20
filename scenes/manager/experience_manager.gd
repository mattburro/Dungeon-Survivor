extends Node

@export var experience_growth_curve: Curve

signal experience_updated(current_experience: float, target_experience: float)
signal level_up(new_level: int)

var target_experience_growth = 1
var current_experience = 0
var target_experience = 3
var current_level = 1

func _ready():
	GameEvents.experience_vial_collected.connect(on_experience_vial_collected)

func add_experience(number: float):
	current_experience += number
	
	if (current_experience >= target_experience):
		current_experience -= target_experience
		target_experience += target_experience_growth
		current_level += 1
		target_experience_growth = round(experience_growth_curve.sample(min(float(current_level) / 70, 1)))
		level_up.emit(current_level)
	
	experience_updated.emit(current_experience, target_experience)

func on_experience_vial_collected(number: float):
	add_experience(number)
