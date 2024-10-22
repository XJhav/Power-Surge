extends Node

var base_wave_stats : WaveStats = preload("res://BaseWaveStats.tres").duplicate()
var time_since_start : float = 0.0

func _process(delta):
	time_since_start += delta

func current_melee_value():
	return clamp(base_wave_stats.get_melee_value(time_since_start), 0 , 100)

func current_ranged_value():
	return clamp(base_wave_stats.get_ranged_value(time_since_start), 0 , 100)

func current_enemy_value():
	return clamp(base_wave_stats.get_enemy_value(time_since_start), 0 , 100)
