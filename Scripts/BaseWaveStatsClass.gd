class_name WaveStats
extends Resource


@export_range(0.01, 2, 0.01) var time_scaling_constant : float = 1.0
@export_group("Melee Stats")
@export var melee_amplitude : float = 1
@export var melee_frequency : float = 1
@export var melee_add_on : float = 1:
	set(value):
		melee_add_on = clamp(value, 0, 100)

@export_group("Ranged Stats")
@export var ranged_amplitude : float = 1
@export var ranged_frequency : float = 1
@export var ranged_add_on : float = 0:
	set(value):
		ranged_add_on = clamp(value, 0, 100)

@export_group("Enemy Stats")
@export var enemy_amplitude : float = 1
@export var enemy_frequency : float = 1
@export var enemy_add_on : float = 0:
	set(value):
		enemy_add_on = clamp(value, 0, 100)

func get_melee_value(time : float):
	return (melee_amplitude * sin(melee_frequency * time * time_scaling_constant)) + melee_add_on

func get_ranged_value(time : float):
	return (ranged_amplitude * cos(ranged_frequency * time * time_scaling_constant + deg_to_rad(90))) + ranged_add_on

func get_enemy_value(time : float):
	return (enemy_amplitude * sin(enemy_frequency * time * time_scaling_constant + deg_to_rad(90))) + enemy_add_on
