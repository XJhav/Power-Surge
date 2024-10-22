class_name Enemy
extends Resource

@export var sprite_frames : SpriteFrames
@export_group("Stats")
@export_range(1, 20, 1) var base_max_health : int = 5
@export_range(5, 100, 5) var base_speed : float = 25
@export_enum("Ranged", "Melee") var attack_type : String = "Ranged"
@export_range(0.25, 2, 0.05) var time_between_shots : float = 0.5
@export_range(1, 10, 1) var base_damage : int = 2
@export var bullet_color : String = "Orange"
@export_range(0,1,0.01) var drop_change : float = 0.15
