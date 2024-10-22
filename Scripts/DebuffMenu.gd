extends Panel

@onready var v_box_container = $VBoxContainer

var debuff_option_object = preload("res://Scenes/debuff_option.tscn")

func _ready():
	for i in range(3):
		add_option(GameManager.debuff_list.possible_debuffs.pick_random())
	
func add_option(debuff_type : Debuff):
	var debuff_option = debuff_option_object.instantiate()
	debuff_option.debuff_type = debuff_type
	v_box_container.add_child(debuff_option)
