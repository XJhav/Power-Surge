extends Node2D

func _ready():
	GameManager.enemy_spawners = get_tree().get_nodes_in_group("Enemy Spawner")
	var current_round : int = 1
	var round_in_progress : bool = true
	var enemy_type_list : EnemyTypeList = preload("res://BaseEnemyTypeList.tres").duplicate()
	var debuff_list : DebuffList = preload("res://DebuffList.tres").duplicate()
	
	await get_tree().create_timer(1.25).timeout

	GameManager.spawn_enemies(2)
