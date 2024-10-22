extends TextureButton

@onready var symbol = $Symbol
@onready var label_v_box = $LabelVBox
@onready var label_1 = $LabelVBox/Label1
@onready var label_2 = $LabelVBox/Label2

@export var debuff_type : Debuff
@export_group("Sprites")
@export var melee_sprite : Texture2D
@export var ranged_sprite : Texture2D
@export var enemy_sprite : Texture2D

func _ready():
	match debuff_type.wave_type:
		"Melee":
			symbol.texture = melee_sprite
		"Ranged":
			symbol.texture = ranged_sprite
		"Enemy":
			symbol.texture = enemy_sprite
	
	var sign = "+"
	if debuff_type.value_change_1 < 0:
		sign = ""
	
	label_1.text = debuff_type.wave_parameter_1 + ": " + sign + str(debuff_type.value_change_1)
	if debuff_type.wave_parameter_2 != "None":
		sign = "+"
		if debuff_type.value_change_1 < 0:
			sign = ""
			
		label_2.text = debuff_type.wave_parameter_2 + ": " + str(debuff_type.value_change_2)
	else:

		label_2.queue_free()


func _on_pressed():
	for button in get_tree().get_nodes_in_group("Debuff Button"):
		button.disabled = true
	
	debuff_type.apply_debuffs()
	GameManager.start_next_round()
	GameManager.debuff_list.possible_debuffs.remove_at(GameManager.debuff_list.possible_debuffs.find(debuff_type))
