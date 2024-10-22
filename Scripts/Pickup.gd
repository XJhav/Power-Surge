extends Area2D

@onready var sprite_2d = $Sprite2D

@export_enum("Health", "Mana") var pickup_type : String = "Health"
@export var heart_sprite : Texture2D
@export var mana_sprite : Texture2D

func _ready():
	print("ayay")
	match pickup_type:
		"Health":
			sprite_2d.texture = heart_sprite
		"Mana":
			sprite_2d.texture = mana_sprite
		_:
			pass

func _on_body_entered(body):
	if !body.is_in_group("Player"):
		return
	
	if pickup_type == "Health":
		body.health += 5
	elif pickup_type == "Mana":
		body.mana += 5
	queue_free()
