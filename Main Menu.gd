extends Node2D

var main_scene : PackedScene = preload("res://Scenes/main.tscn")

func _on_play_button_pressed():
	get_tree().change_scene_to_packed(main_scene)
