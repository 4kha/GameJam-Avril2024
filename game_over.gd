extends Node2D
@onready var global = get_node("/root/Score")

func _ready():
	$RichTextLabel2.text = "Score " + str(global.global_score) 
	$AudioStreamPlayer2D.play()

func _on_button_pressed():
	get_tree().change_scene_to_file("res://introduction.tscn")



func _on_button_pressed2():
		get_tree().change_scene_to_file("res://menu.tscn")
