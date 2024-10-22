class_name Debuff
extends Resource

@export_enum("Melee", "Ranged", "Enemy") var wave_type : String = "Melee"
@export_group("Debuff 1")
@export_enum("Amplitude", "Frequency", "Vert. Shift") var wave_parameter_1 : String = "Amplitude"
@export_range(-2,2,1) var value_change_1 : int = 0
@export_group("Debuff 2")
@export_enum("Amplitude", "Frequency", "Vert. Shift", "None") var wave_parameter_2 : String = "None"
@export_range(-2,2,1) var value_change_2 : int = 0

func apply_debuffs():
	var stat_name1 = wave_type_to_prefix(wave_type) + parameter_to_suffix(wave_parameter_1)
	var current_stat1_value = GraphManager.base_wave_stats.get(stat_name1)
	GraphManager.base_wave_stats.set(stat_name1, current_stat1_value + value_change_1)
	
	print(stat_name1 + ': ' + str(GraphManager.base_wave_stats.get(stat_name1)))
	
	if wave_parameter_2 == "None":
		return
		
	var stat_name2 = wave_type_to_prefix(wave_type) + parameter_to_suffix(wave_parameter_2)
	var current_stat2_value = GraphManager.base_wave_stats.get(stat_name2)
	GraphManager.base_wave_stats.set(stat_name2, current_stat2_value + value_change_2)
	
	print(stat_name2 + ': ' + str(GraphManager.base_wave_stats.get(stat_name2)))

func wave_type_to_prefix(given_wave_type : String):
	match given_wave_type:
		"Melee":
			return "melee_"
		"Ranged":
			return "ranged_"
		"Enemy":
			return "enemy_"
		_:
			return ""

func parameter_to_suffix(parameter : String):
	match parameter:
		"Amplitude":
			return "amplitude"
		"Frequency":
			return "frequency"
		"Vert. Shift":
			return "add_on"
		_:
			return "none"
