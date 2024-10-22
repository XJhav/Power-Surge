extends Control

@onready var pause_panel = $PausePanel
@onready var dead_panel = $DeadPanel
@onready var win_panel = $WinPanel

@onready var hp_bar = $"UpLeftHUD/HP Bar"
@onready var mana_bar = $"UpLeftHUD/Mana Bar"
@onready var weapon_symbol = $UpLeftHUD/WeaponSymbol
@onready var up_hud = $UpHUD

@onready var sword_graph_icon = $DownLeftHUD/SwordIcon
@onready var magic_graph_icon = $DownLeftHUD/MagicIcon
@onready var enemy_graph_icon = $DownLeftHUD/EnemyIcon

@onready var sword_label = $LeftHUD/SwordPanel/SwordLabel
@onready var magic_label = $LeftHUD/MagicPanel/MagicLabel
@onready var enemy_label = $LeftHUD/EnemyPanel/EnemyLabel

@onready var sword_line = $DownLeftHUD/SwordLine
@onready var magic_line = $DownLeftHUD/MagicLine
@onready var enemy_line = $DownLeftHUD/EnemyLine

@export var graph_scale : int = 5
@export_group("Weapon Symbols")
@export var sword_symbol : Texture2D
@export var magic_symbol : Texture2D

func set_hp_progress(health : int, max_health : int):
	if hp_bar == null:
		return
	hp_bar.max_value = max_health
	hp_bar.value = health

func set_mana_progress(mana : int, max_mana : int):
	if mana_bar == null:
		return
	mana_bar.max_value = max_mana
	mana_bar.value = mana

func _process(delta):
	set_line_points()
	update_weapon_symbol()
	update_labels()
	
	if GameManager.round_in_progress:
		up_hud.text = "Current Round: " + str(GameManager.current_round) + " / 10"
	else:
		up_hud.text = ""

func set_line_points():
	var sword_points : Array[Vector2] = []
	for i in range(13):
		sword_points.append(Vector2(i * 4.5, clamp(43 + GraphManager.base_wave_stats.get_melee_value(GraphManager.time_since_start + 6 - i * 0.5) * graph_scale * -1, -43, 43)))
	sword_line.points = sword_points
	sword_graph_icon.position.y = clamp(GraphManager.current_melee_value() * graph_scale * -1 + 86, 2, 85)

	var magic_points : Array[Vector2] = []
	for i in range(13):
		magic_points.append(Vector2(i * 4.5, clamp(43 + GraphManager.base_wave_stats.get_ranged_value(GraphManager.time_since_start + 6 - i * 0.5) * graph_scale * -1, -43, 43)))
	magic_line.points = magic_points
	magic_graph_icon.position.y = clamp(GraphManager.current_ranged_value() * graph_scale * -1 + 86, 2, 85)

	var enemy_points : Array[Vector2] = []
	for i in range(13):
		enemy_points.append(Vector2(i * 4.5, clamp(43 + GraphManager.base_wave_stats.get_enemy_value(GraphManager.time_since_start + 6 - i * 0.5) * graph_scale * -1, -43, 43)))
	enemy_line.points = enemy_points
	enemy_graph_icon.position.y = clamp(GraphManager.current_enemy_value() * graph_scale * -1 + 86, 2, 85)

func update_weapon_symbol():
	if GameManager.player == null or not is_instance_valid(GameManager.player):
		return
	
	if GameManager.player.selected_attack == "Melee":
		weapon_symbol.texture = sword_symbol
	elif GameManager.player.selected_attack == "Ranged":
		weapon_symbol.texture = magic_symbol

func update_labels():
	sword_label.text = str(round(GraphManager.current_melee_value()))
	magic_label.text = str(round(GraphManager.current_ranged_value()))
	enemy_label.text = str(round(GraphManager.current_enemy_value()))


func _on_main_menu_button_pressed():
	if !GameManager.paused:
		GameManager.paused = true
		pause_panel.visible = true
		Engine.time_scale = 0

func _input(event):
	if event.is_action_pressed("fire") and GameManager.paused:
		GameManager.paused = false
		pause_panel.visible = false
		Engine.time_scale = 1

func enable_dead_panel(parity : bool):
	dead_panel.visible = parity

func enable_win_panel():
	win_panel.visible = true
	
