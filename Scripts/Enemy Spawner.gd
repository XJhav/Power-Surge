extends Node2D

var can_spawn : bool = true
var enemy_object : PackedScene = preload("res://Scenes/enemy.tscn")

func spawn_enemy(enemy_type : Enemy):
	if !can_spawn:
		return
	can_spawn = false
	
	var new_enemy = enemy_object.instantiate()
	new_enemy.enemy_type = enemy_type
	get_tree().root.add_child(new_enemy)
	new_enemy.position = position
	
	await get_tree().create_timer(1).timeout
	
	can_spawn = true
