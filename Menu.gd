extends Node2D
var tuto = 0
var page = 1

func _ready():
	hide_all()
	show_page()

func _process(_delta):
	pass
	
func _on_button_pressed():
	if tuto == 0:
		$AudioStreamPlayer2D.play()
		get_tree().change_scene_to_file("res://introduction.tscn")


func _on_button_pressed_tutoriel():
	tuto_on()
	tuto = 1
	$AudioStreamPlayer2D.play()
	
func tuto_on():
	var tween = create_tween()
	tween.tween_property($CanvasLayer, "offset", Vector2(0, 480), 0.5).set_trans(tween.TRANS_SPRING)
	
func tuto_off():
	var tween = create_tween()
	tween.tween_property($CanvasLayer, "offset", Vector2(0, 0), 0.5).set_trans(tween.TRANS_SPRING)


func _on_button_pressed_tutoriel_x():
	tuto_off()
	$AudioStreamPlayer2D.play()
	tuto = 0

func hide_all():
	$CanvasLayer/Canvas/Tuto1.hide()
	$CanvasLayer/Canvas/Tuto2.hide()
	$CanvasLayer/Canvas/Tuto3.hide()

func show_page():
	if page == 1:
		$CanvasLayer/Canvas/Tuto1.show()
		$CanvasLayer/Canvas/Next.show()
		$CanvasLayer/Canvas/Next2.hide()
	if page == 2:
		$CanvasLayer/Canvas/Tuto2.show()
		$CanvasLayer/Canvas/Next.hide()
		$CanvasLayer/Canvas/Next2.show()
#	if page == 3:
#		$CanvasLayer/Canvas/Tuto3.show()
#		$CanvasLayer/Canvas/Next.hide()
#		$CanvasLayer/Canvas/Next2.show()

func _on_button_pressed1():
	if page > 1:
		page -= 1
	hide_all()
	show_page()

func _on_button_pressed2():
	if page < 2:
		page += 1
	hide_all()
	show_page()
