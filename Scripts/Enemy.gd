extends Area2D


@onready var animated_sprite = $AnimatedSprite2D
@onready var shot_timer = $ShotTimer
@onready var animator = $Animator
@onready var health_bar = $HealthBar

@export var enemy_type : Enemy
var bullet_object : PackedScene = preload("res://Scenes/enemy_bullet.tscn")
var damage_num_object : PackedScene = preload("res://Scenes/damage_number.tscn")
var pickup_object : PackedScene = preload("res://Scenes/pickup.tscn")

var flash_state_value : float = 0
var player : Node2D
var currently_processing : bool = false
var health : int = 5:
	set(value):
		health = clamp(value, 0, enemy_type.base_max_health)
		$HealthBar.max_value = enemy_type.base_max_health
		$HealthBar.value = health

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	
	animated_sprite.sprite_frames = enemy_type.sprite_frames
	animated_sprite.play("default")
	health = enemy_type.base_max_health
	
	shot_timer.wait_time = enemy_type.time_between_shots

func _physics_process(delta):
	if !currently_processing:
		return
	
	position = GameManager.clamp_position(position)
	update_flash_state(flash_state_value)
	update_facing_direction()
	melee_move(delta)

func melee_move(amount : float):
	if enemy_type.attack_type != "Melee":
		return
	
	position += (player.position - position).normalized() * enemy_type.base_speed * amount 

func take_knockback(inflicted_position : Vector2, amount : float):
	var knockback_tween = create_tween()
	
	var knockback_direction = (position - inflicted_position).normalized()
	
	knockback_tween.tween_property(self, "position", GameManager.clamp_position(position + knockback_direction * amount), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

func take_damage(amount : int):
	health -= amount
	
	create_damage_num(amount)
	
	var flash_tween = create_tween()
	
	flash_state_value = 1.0
	flash_tween.tween_property(self, "flash_state_value", 0, 0.3)
	
	check_die()
	print(health)

func check_die():
	if health <= 0:
		animator.play("Die")
		
		if randf() <= enemy_type.drop_change:
			var pickup = pickup_object.instantiate()
			pickup.pickup_type = ["Health", "Mana"].pick_random()
			get_tree().root.add_child(pickup)
			pickup.position = position
		
		GameManager.check_enemies()

func ranged_attack():
	var bullet = bullet_object.instantiate()
	bullet.damage = floor(enemy_type.base_damage * GraphManager.current_enemy_value())
	bullet.direction = (player.position - position).normalized()
	bullet.color = enemy_type.bullet_color
	get_tree().root.add_child(bullet)
	bullet.position = position

func enable_processing():
	currently_processing = true
	monitoring = true
	monitorable = true
	if enemy_type.attack_type == "Ranged":
		shot_timer.start()
	

func update_facing_direction():
	if player.position.x > position.x:
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false

func _on_body_entered(body):
	if body.is_in_group("Player") and health > 0:
		body.take_damage(floor(enemy_type.base_damage * GraphManager.current_enemy_value()))
		take_knockback(body.position, 25)

func _on_shot_timer_timeout():
	if enemy_type.attack_type == "Ranged" and health > 0:
		ranged_attack()

func update_flash_state(value):
	animated_sprite.material.set_shader_parameter("flashState", value)

func create_damage_num(number : int):
	var damage_num = damage_num_object.instantiate()
	damage_num.text = str(number)
	damage_num.position_to_start = Vector2.UP * 15 + Vector2.LEFT * 2
	add_child(damage_num)
