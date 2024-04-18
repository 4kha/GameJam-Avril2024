extends Node2D
const SHAKE_STRENGHT = 4
var shaking = 0
var next = 0
var skip = 0
@onready var global = get_node("/root/Score")

func _ready():
	$Button.hide()
	$AudioStreamPlayer2D.play()
	$AnimationPlayer.play("intro")
	$AnimationPlayer/House/magic.play()
	$AnimationPlayer/Squeletton2.play()
	$AnimationPlayer/Squeletton3.play()
	$AnimationPlayer/Squeletton4.play()
	$AnimationPlayer/Fireball.play()
	$AnimationPlayer/Player.play()
	global.skipped = 0

func _process(_delta):
	if shaking == 1:
		$AnimationPlayer/House.offset = Randshake()
	if skip == 1:
		global.skipped = 1
		next = 1
	if next == 1:
		get_tree().change_scene_to_file("res://main.tscn")
	
func shake_house():
	shaking = 1
	$Timer.start()

func Randshake():
	return (Vector2(randf_range(-1, 1) * SHAKE_STRENGHT, randf_range(-1, 1) * SHAKE_STRENGHT))

func _on_timer_timeout():
	shaking = 0
	$AnimationPlayer/House.offset = Vector2(0, 0)


func _on_animation_player_animation_finished(_anim_name):
	next = 1
	
func _input(event):
	if event.is_action_pressed("skip"):
		skip = 1
	if event.is_action_pressed("leftclick") or event.is_action_pressed("rightclick"):
		$Button.show()

func _on_button_pressed():
	skip = 1
