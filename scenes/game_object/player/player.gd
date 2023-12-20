extends CharacterBody2D

@export var arena_time_manager: Node

@onready var damage_interval_timer = $DamageIntervalTimer
@onready var health_component = $HealthComponent
@onready var health_bar = $HealthBar
@onready var abilities = $Abilities
@onready var animation_player = $AnimationPlayer
@onready var visuals = $Visuals
@onready var velocity_component = $VelocityComponent
@onready var pickup_collision_shape_2d = %PickupCollisionShape2D

var last_movement_direction: Vector2 = Vector2.ZERO
var number_colliding_bodies = 0
var base_speed = 0
var immobilized: bool = false

func _ready():
	base_speed = velocity_component.max_speed
	$CollisionArea2D.body_entered.connect(on_body_entered)
	$CollisionArea2D.body_exited.connect(on_body_exited)
	$CollisionArea2D.area_entered.connect(on_area_entered)
	$CollisionArea2D.area_exited.connect(on_area_exited)
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)
	health_component.health_decreased.connect(on_health_decreased)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	arena_time_manager.health_regen_tick.connect(on_health_regen_tick)
	
	process_meta_upgrades()
	update_health_display()

func _process(delta):
	var movement_vector = get_movement_vector()
	var direction = movement_vector.normalized()
	
	if !immobilized:
		velocity_component.accelerate_in_direction(direction)
		velocity_component.move(self, delta)
	
	if movement_vector.x != 0 || movement_vector.y != 0:
		last_movement_direction = direction
		animation_player.play("walk")
	else:
		animation_player.play("RESET")
	
	var move_sign = sign(movement_vector.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)

func get_movement_vector():
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")	
	
	return Vector2(x_movement, y_movement)

func check_deal_damage():
	if number_colliding_bodies == 0 || !damage_interval_timer.is_stopped():
		return
	
	health_component.take_damage(1.0)
	damage_interval_timer.start()

func update_health_display():
	health_bar.value = health_component.get_health_percent()

func process_meta_upgrades():
	var base_pickup_range = pickup_collision_shape_2d.shape.radius
	var additional_pickup_range_percentage = 1.0 + (MetaProgression.get_upgrade_count("experience_range") * 0.15)
	pickup_collision_shape_2d.shape.radius = base_pickup_range * additional_pickup_range_percentage
	
	var base_max_health = health_component.max_health
	var additional_max_health_percentage = 1.0 + (MetaProgression.get_upgrade_count("max_health") * 0.2)
	health_component.max_health = round(base_max_health * additional_max_health_percentage)
	health_component.current_health = health_component.max_health

func on_body_entered(other_body: Node2D):
	number_colliding_bodies += 1
	check_deal_damage()

func on_body_exited(other_body: Node2D):
	number_colliding_bodies -= 1

func on_area_entered(other_area: Area2D):
	if other_area.is_in_group("spiderweb"):
		if !immobilized:
			immobilized = true
			other_area.global_position = global_position
			other_area.velocity = Vector2.ZERO
			other_area.rotation = deg_to_rad(90)
			
			var web_timer = other_area.timer as Timer
			web_timer.stop()
			web_timer.wait_time = other_area.web_time
			web_timer.start()
			await web_timer.timeout
			immobilized = false
		else:
			other_area.close()
	elif other_area.is_in_group("rock"):
		number_colliding_bodies += 1
		check_deal_damage()
		other_area.explode()

func on_area_exited(other_area: Area2D):
	if other_area.is_in_group("rock"):
		number_colliding_bodies -= 1

func on_damage_interval_timer_timeout():
	check_deal_damage()

func on_health_decreased():
	GameEvents.emit_player_damaged()
	$RandomHitSoundPlayer.play_random()
	update_health_display()

func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if ability_upgrade is Ability:
		var ability = ability_upgrade as Ability
		abilities.add_child(ability.ability_controller_scene.instantiate())
	elif ability_upgrade.id == "player_speed":
		velocity_component.max_speed = base_speed + (base_speed * current_upgrades["player_speed"]["quantity"] * 0.15)

func on_health_regen_tick():
	var heal_amount = MetaProgression.get_upgrade_count("health_regeneration")
	if heal_amount > 0:
		health_component.heal(heal_amount)
		update_health_display()
