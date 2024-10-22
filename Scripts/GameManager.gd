extends Node

var dead := false
var paused := false
var main_menu_scene : PackedScene = preload("res://Scenes/main_menu.tscn")
var main_scene : PackedScene = preload("res://Scenes/main.tscn")

var current_round : int = 1
var round_in_progress : bool = true
var enemy_spawners : Array[Node] = []
var debuff_menu_object : PackedScene = preload("res://Scenes/debuff_menu.tscn")
var enemy_type_list : EnemyTypeList = preload("res://BaseEnemyTypeList.tres").duplicate()
var debuff_list : DebuffList = preload("res://DebuffList.tres").duplicate()
var enemies : Array[Node]:
	get:
		return get_tree().get_nodes_in_group("Enemy")

var player : Node2D:
	get:
		if get_tree().get_first_node_in_group("Player") == null:
			return null
		return get_tree().get_first_node_in_group("Player")

func spawn_enemies(number_of_enemies : int):
	enemy_spawners = get_tree().get_nodes_in_group("Enemy Spawner")
	
	for i in range(number_of_enemies):
		if enemy_spawners == [] or enemy_type_list.enemy_types == []:
			return

		var selected_enemy_spawner = enemy_spawners.pick_random()
		var enemy_type = enemy_type_list.enemy_types.pick_random()
		enemy_spawners.remove_at(enemy_spawners.find(selected_enemy_spawner))
		
		selected_enemy_spawner.spawn_enemy(enemy_type)

func clamp_position(old_position : Vector2) -> Vector2:
	var new_position : Vector2 = Vector2.ZERO
	new_position.x = clamp(old_position.x, -138, 138)
	new_position.y = clamp(old_position.y, -82, 82)
	return new_position

func check_enemies():
	var enemies_duplicate = enemies.duplicate()
	
	for enemy in enemies_duplicate.duplicate():
		if enemy.health <= 0:
			enemies_duplicate.remove_at(enemies_duplicate.find(enemy))
	
	if len(enemies_duplicate) == 0:
		between_rounds_sequence()

func between_rounds_sequence():
	if round_in_progress == false:
		return
	if current_round >= 10:
		win()
	
	round_in_progress = false
	for bullet in get_tree().get_nodes_in_group("Enemy Bullet"):
		bullet.queue_free()
	for pickup in get_tree().get_nodes_in_group("Pickup"):
		pickup.queue_free()
	player.mana = player.max_mana
	player.health += 5
	
	await get_tree().create_timer(0.5).timeout
	player.currently_processing = false
	spawn_debuff_menu()

func start_next_round():
	current_round += 1
	round_in_progress = true
	player.currently_processing = true
	await remove_debuff_menu()
	
	await get_tree().create_timer(0.5).timeout
	
	if current_round <= 2:
		spawn_enemies(2)
	elif current_round <= 4:
		spawn_enemies(3)
	elif current_round <= 6:
		spawn_enemies(4)
	elif current_round <= 10:
		spawn_enemies(6)
	else:
		spawn_enemies(6)

func win():
	player.currently_processing = false
	
	get_tree().get_first_node_in_group("UI").enable_win_panel()


func spawn_debuff_menu():
	var debuff_menu = debuff_menu_object.instantiate()
	get_tree().root.add_child(debuff_menu)
	debuff_menu.position = Vector2(-240,-640)
	
	var menu_tween = create_tween()
	menu_tween.tween_property(debuff_menu, "position", Vector2(-240,-240), 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	await menu_tween.finished
	pass

func remove_debuff_menu():
	var debuff_menu = get_tree().get_first_node_in_group("Debuff Menu")
	if debuff_menu == null:
		return
	
	var menu_tween = create_tween()
	menu_tween.tween_property(debuff_menu, "position", Vector2(-240,160), 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await menu_tween.finished
	debuff_menu.queue_free()

func load_main_menu():
	player.currently_processing = false
	await get_tree().process_frame
	player.queue_free()
	get_tree().get_first_node_in_group("UI").queue_free()
	for enemy in enemies:
		enemy.currently_processing = false
		
		queue_free()
	await get_tree().process_frame
	
	get_tree().change_scene_to_packed(main_menu_scene)
