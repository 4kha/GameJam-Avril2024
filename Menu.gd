extends Node2D

func _on_button_pressed():
	$AudioStreamPlayer2D.play()
	get_tree().change_scene_to_file("res://introduction.tscn")
