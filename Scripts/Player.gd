extends CharacterBody2D

@onready var collider = $Collider
@onready var animated_sprite = $AnimatedSprite
@onready var bullet_ray = $BulletRay
@onready var animator = $Animator
@onready var bullet_line_render = $BulletRender
@onready var sword_collider = $SwordCollider
@onready var mana_regen_timer = $ManaRegenTimer
@onready var rotating_sprite = $RotatingSprite
@onready var sword_refresh_timer = $SwordRefreshTimer

var damage_num_object = preload("res://Scenes/damage_number.tscn")

@export_group("Sounds")
@export var shoot_sound : Sound
@export var swing_sound : Sound
@export var damage_sound : Sound
@export_group("Player Stats")
@export_subgroup("Basic Stats")
@export var max_health : int = 10
@export_range(10, 80, 5) var move_speed : float = 5.0
@export_subgroup("Ranged Attack")
@export var base_ranged_damage : int = 1
@export_range(0.25, 2, 0.05) var mana_regen_rate : float = 1.0:
	set(value):
		$ManaRegenTimer.wait_time = value
		mana_regen_rate = value
@export_range(0.01, 0.5, 0.01) var time_between_shots : float = 0.21
@export_range(10, 500) var bullet_range : float = 500
@export_range(10, 500) var bullet_min_range : float = 40
@export var max_mana : int = 10
@export var bullet_knockback : float = 5
@export_subgroup("Melee Attack")
@export var sword_move_amount : int = 20
@export var max_sword_swings : int = 3
@export_range(0.01, 0.5, 0.01) var time_between_swings : float = 0.1
@export var sword_knockback : float = 4
@export var sword_rotation_offset : float = 30
var selected_attack : String = "Melee"
var health : int:
	set(value):
		health = clamp(value, 0, max_health)
		update_ui_progress_bars()

var mana : int:
	set(value):
		mana = clamp(value, 0 , max_mana)
		update_ui_progress_bars()

var currently_processing : bool = false
var can_shoot : bool = true
var can_swing : bool = true
var facing_direction : Vector2 = Vector2(0,0)
var sword_swing_number : int = 1
var sword_locked : bool = false
var weapon_facing_direction : Vector2 = Vector2(0,0)
var current_animation: String = ""
var flash_state_value : float = 0

func _ready():
	
	mana_regen_timer.wait_time = mana_regen_rate
	health = max_health
	mana = max_mana
	
	update_rotating_sprite()
	update_ui_progress_bars()
	
	bullet_ray.add_exception(sword_collider)

func _physics_process(delta):
	if !currently_processing:
		return
	
	facing_direction.x = Input.get_axis("move_left", "move_right")
	facing_direction.y = Input.get_axis("move_up", "move_down")
	
	if !sword_locked:
		weapon_facing_direction = (get_global_mouse_position() - global_position).normalized()
	
	velocity = facing_direction.normalized() * move_speed * delta * 500
	
	position = GameManager.clamp_position(position)
	update_flash_state(flash_state_value)
	update_sprite_direction()
	update_sword_collider()
	update_rotating_sprite()
	move_and_slide()

func _input(event):
	if event.is_action_pressed("switch_weapon") and currently_processing and !GameManager.paused:
		if selected_attack == "Melee":
			selected_attack = "Ranged"
		elif selected_attack == "Ranged":
			selected_attack = "Melee"
	
	if event.is_action_pressed("fire")  and currently_processing and !GameManager.paused:
		if selected_attack == "Melee" and can_swing:
			swing_sword()
		elif selected_attack == "Ranged" and can_shoot:
			shoot_bullet()

func take_damage(damage : int):
	if health > 0:
		var flash_tween = create_tween()
		flash_state_value = 1.0
		flash_tween.tween_property(self, "flash_state_value", 0, 0.3)
		health -= damage
		
		AudioManager.play_sound(damage_sound)
		
		create_damage_num(damage)
		check_die()

func check_die():
	if health <= 0:
		die()

func die():
	for enemy in GameManager.enemies:
		enemy.currently_processing = false
	currently_processing = false
	GameManager.dead = true
	get_tree().get_first_node_in_group("UI").enable_dead_panel(true)

func swing_sword():
	if sword_swing_number > max_sword_swings:
		return
	
	AudioManager.play_sound(swing_sound)
	
	can_swing = false
	sword_locked = true
	sword_swing_number += 1
	sword_refresh_timer.start(0)
	
	var sword_rotation_tween = create_tween()
	
	if sword_rotation_offset > 0:
		sword_rotation_tween.tween_property(self, "sword_rotation_offset", -30, 0.1)
	elif sword_rotation_offset <= 0:
		sword_rotation_tween.tween_property(self, "sword_rotation_offset", 30, 0.1)
	
	var swing_movement_tween = create_tween()
	swing_movement_tween.tween_property(self, "position", GameManager.clamp_position(position + weapon_facing_direction * sword_move_amount * (sword_swing_number - 2)), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	check_sword_hits()
	await sword_rotation_tween.finished
	refresh_shot()

func check_sword_hits():
	
	var hit_objects : Array[Area2D] = sword_collider.get_overlapping_areas()
	
	if hit_objects == []:
		return
	
	for object in hit_objects:
		if object.is_in_group("Enemy"):
			object.take_damage(round(GraphManager.current_melee_value()))
			object.take_knockback(position, sword_knockback * (sword_swing_number - 1) + 5)

func shoot_bullet():
	if mana <= 0:
		return
	mana -= 1
	
	AudioManager.play_sound(shoot_sound)
	can_shoot = false
	bullet_ray.target_position = (get_global_mouse_position() - global_position).normalized() * bullet_range
	bullet_ray.enabled = true
	
	check_bullet_hits()
	show_bullet()
	
	bullet_ray.enabled = false

func check_bullet_hits():
	bullet_ray.force_raycast_update()
	bullet_ray.force_update_transform()
	
	var hit_object : Area2D = bullet_ray.get_collider()
	if hit_object == null:
		return
	
	if hit_object.is_in_group("Enemy"):
		hit_object.take_damage(round(GraphManager.current_ranged_value()))
		hit_object.take_knockback(position, -2 * bullet_knockback)

func show_bullet():
	bullet_line_render.points[0] = (get_global_mouse_position() - global_position).normalized() * bullet_min_range
	
	var hit_object : Area2D = bullet_ray.get_collider()
	
	if hit_object != null:
		bullet_line_render.points[1] = (get_global_mouse_position() - global_position).normalized() * position.distance_to(hit_object.position)
	else:
		bullet_line_render.points[1] = bullet_ray.target_position
	
	mana_regen_timer.stop()
	
	var bullet_flash_tween : Tween = create_tween()
	bullet_line_render.visible = true
	bullet_line_render.default_color = Color.LEMON_CHIFFON
	bullet_flash_tween.tween_property(bullet_line_render, "default_color", Color(0.8,0.6,0,0), 0.2).set_ease(Tween.EASE_IN)
	
	await bullet_flash_tween.finished
	await get_tree().create_timer(time_between_shots - 0.2).timeout
	
	refresh_shot()
	mana_regen_timer.start(0)
	bullet_line_render.visible = false

func refresh_shot():
	can_shoot = true
	can_swing = true

func update_sword_collider():
	if selected_attack == "Melee":
		sword_collider.monitoring = true
		sword_collider. position = weapon_facing_direction * 30
	else:
		sword_collider.monitoring = false

func update_rotating_sprite():
	if selected_attack == "Melee":
		rotating_sprite.animation = "Sword"
		rotating_sprite.rotation = weapon_facing_direction.angle() + deg_to_rad(90)+ deg_to_rad(sword_rotation_offset)
		rotating_sprite.position = angle_to_vector2(weapon_facing_direction.angle() + deg_to_rad(sword_rotation_offset)) * 20
	elif selected_attack == "Ranged":
		rotating_sprite.animation = "Gun"
		rotating_sprite.rotation = weapon_facing_direction.angle() + deg_to_rad(90)
		rotating_sprite.position = (get_global_mouse_position() - global_position).normalized() * 20

func update_ui_progress_bars():
	var ui : Node = get_tree().get_first_node_in_group("UI")
	
	if health == null or mana == null:
		return
	ui.set_hp_progress(health, max_health)
	ui.set_mana_progress(mana, max_mana)

func update_sprite_direction():
	if weapon_facing_direction.y > 0:
		animated_sprite.animation = "Downfacing"
	elif weapon_facing_direction.y < 0:
		animated_sprite.animation = "Upfacing"
	
	if weapon_facing_direction.x > 0:
		animated_sprite.flip_h = false
	elif weapon_facing_direction.x < 0:
		animated_sprite.flip_h = true

func _on_mana_regen_timer_timeout():
	mana += 1

func angle_to_vector2(angle_radians: float) -> Vector2:
	return Vector2(cos(angle_radians), sin(angle_radians))

func _on_sword_refresh_timer_timeout():
	sword_swing_number = 1
	sword_locked = false

func enable_processing():
	currently_processing = true

func play_animation(new_animation: String):
	# Check if an animation is currently playing
	if new_animation == "Take_Damage":
		# Finish the current animation immediately
		animator.seek(animator.current_animation_length, true)
		# Wait for the seek to complete (to ensure all properties are applied)
		await get_tree().process_frame
	# Play the new animation
	current_animation = new_animation
	animator.play(current_animation)

func update_flash_state(value):
	animated_sprite.material.set_shader_parameter("flashState", value)

func create_damage_num(number : int):
	var damage_num = damage_num_object.instantiate()
	damage_num.text = str(number)
	damage_num.position_to_start = Vector2.UP * 15 + Vector2.LEFT * 2
	add_child(damage_num)
