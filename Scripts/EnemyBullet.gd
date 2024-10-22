extends Area2D

@onready var sprite = $Sprite2D
@onready var collision_shape_2d = $CollisionShape2D

@export var sprites : Array[Texture2D]

var damage : int = 1
var color : String = "Orange"
var bullet_speed : float = 1
var direction : Vector2 = Vector2(1,0)

func _ready():
	update_sprite()

func _physics_process(delta):
	bounds_check()
	position += direction * delta * bullet_speed * 50

func _on_area_entered(area):
	if area.is_in_group("Player"):
		area.take_damage(damage)
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(damage)
		queue_free()

func update_sprite():
	var sprite_index = 0
	
	if damage >= 5:
		sprite_index += 1
		collision_shape_2d.scale = Vector2(0.5,0.5)
	if color == "Purple":
		sprite_index += 2
	
	sprite.texture = sprites[sprite_index]

func bounds_check():
	if position.x > 141 or position.x < -141 or position.y > 85 or position.y < -85:
		queue_free()
