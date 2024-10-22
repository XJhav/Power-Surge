extends Label

var position_to_start : Vector2 = Vector2.ZERO

func _ready():
	var opacity_tween = create_tween()
	var movement_tween = create_tween()
	
	position = position_to_start
	
	opacity_tween.tween_property(self, "modulate", Color(1,1,1,0), 0.5)
	movement_tween.tween_property(self, "position", Vector2(position.x, position.y - 8), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
