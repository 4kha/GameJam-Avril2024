extends CanvasLayer
#all buff value
var buff_slow_inqui = 0      #1
var buff_fast_necro = 0      #2
var buff_longer_aoe = 0      #3
var buff_cdr_summon = 0      #4
var buff_cdr_flame = 0       #5
var buff_dmg_flame = 0       #6
var buff_cdr_tp = 0          #7
var buff_bigger_tp = 0       #8
var buff_spawn_further = 0   #9
var buff_spawn_faster = 0    #10
var buff_spawn_more = 0      #11
var buff_skeleton_fast = 0   #12
var buff_skeleton_damage = 0 #13
const icon = [1, 2, 3, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
const description = ["Slow the inquisition",
"Move faster",
"Summoning last longer",
"Lower Summoning cooldown",
"Lower Fireball coodlown",
"Fireball does more damage",
"Lower Teleport cooldown",
"Bigger Teleport area",
"Bigger Summoning area",
"Convert building faster",
"Spawn more skeleton",
"Skeleton move faster",
"Skeleton does more damage"]

var selecting = 0
var trio = []

func _ready():
	$AudioStreamPlayer2D2.play()

func _process(_delta):
	pass
	
func upgrade():
	get_tree().paused = true
	set_up_all_buff()
	var tween = create_tween()
	tween.tween_property(self, "offset", Vector2(0, 0), 0.5).set_trans(tween.TRANS_SPRING)

#func send_to_global():
#	global.buff_slow_inqui = buff_slow_inqui
#	global.buff_fast_necro = buff_fast_necro
#	global.buff_longer_aoe = buff_longer_aoe
#	global.buff_cdr_summon = buff_cdr_summon
#	global.buff_cdr_flame = buff_cdr_flame
#	global.buff_dmg_flame = buff_dmg_flame
#	global.buff_cdr_tp = buff_cdr_tp
#	global.buff_bigger_tp = buff_bigger_tp
#	global.buff_spawn_further = buff_spawn_further
#	global.buff_spawn_faster = buff_spawn_faster
#	global.buff_spawn_more = buff_spawn_more
#	global.buff_skeleton_fast = buff_skeleton_fast
#	global.buff_skeleton_damage = buff_skeleton_damage

func set_up_all_buff():
	trio = select_trio()
	set_button($Sprite2D/Button1, trio[0])
	set_button($Sprite2D/Button2, trio[1])
	set_button($Sprite2D/Button3, trio[2])
	selecting = 1

func set_button(button, n):
	button.get_node("Label").text = get_description(n)
	button.get_node("AnimatedSprite2D").play(str(get_button(n)))
	
func select_trio():
	var grab = []
	var value = 0
	grab.append(randi_range(0, 12))
	while (grab.size()  < 3):
		value = randi_range(1, 12)
		if grab.find(value, 0) == -1:
			grab.append(value)
	return (grab)

func get_button(n):
	return(icon[n])

func get_description(n):
	return(description[n])

func buff_1():
	buff_slow_inqui += 1
	
func buff_2():
	buff_fast_necro += 1
	
func buff_3():
	buff_longer_aoe += 1
	
func buff_4():
	buff_cdr_summon += 1
	
func buff_5():
	buff_cdr_flame += 1
	
func buff_6():
	buff_dmg_flame += 1
	
func buff_7():
	buff_cdr_tp += 1
	
func buff_8():
	buff_bigger_tp += 1
	
func buff_9():
	buff_spawn_further += 1
	
func buff_10():
	buff_spawn_faster += 1
	
func buff_11():
	buff_spawn_more += 1

func buff_12():
	buff_skeleton_fast += 1
	
func buff_13():
	buff_skeleton_damage += 1
	
func apply_buff(n):
	if n == 0:
		buff_1()
	elif n == 1:
		buff_2() 
	elif n == 2:
		buff_3() 
	elif n == 3:
		buff_4() 
	elif n == 4:
		buff_5() 
	elif n == 5:
		buff_6() 
	elif n == 6:
		buff_7() 
	elif n == 7:
		buff_8() 
	elif n == 8:
		buff_9() 
	elif n == 9:
		buff_10() 
	elif n == 10:
		buff_11() 
	elif n == 11:
		buff_12() 
	elif n == 12:
		buff_13()

func pressed(button):
	if selecting == 1:
		var tween = create_tween()
		apply_buff(trio[button])
		tween.tween_property(self, "offset", Vector2(0, -470), 0.5).set_trans(tween.TRANS_SPRING)
		get_tree().paused = false
		$AudioStreamPlayer2D.play()
		
	selecting = 0
	
func _on_button1_pressed():
	pressed(0)

func _on_button2_pressed():
	pressed(1)

func _on_button3_pressed():
	pressed(2)

func _on_audio_stream_player_2d_2_finished():
	$AudioStreamPlayer2D2.play()
