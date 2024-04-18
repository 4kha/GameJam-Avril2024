extends Node2D

@onready var progress = $progress
@onready var camera = get_node("../Camera2D")
@onready var upgrade = get_tree().get_root().get_node("./main/Upgrade")
@onready var global = get_node("/root/Score")
signal inquisition_move
var inquisition_army = 1
var undead_army = 0
var difficulty = 1
var score = 0
var timer_counter = 0
var divide = float(0.0)
var target_value = 0
var speed_inquisition = 0 
var muted = false
var full_army = 0
var scaling = 0
var distance = 0
var safe_time = 0
var max_speed = 0
var tutodone = 0

func _ready():
	get_node("../Label").hide()
	$progress.max_value = 4
	$progress.value = 2
	$progress/Divider.position.x = 0
	$progress/Divider/Divider.hide()
	connect("inquisition_move", Callable(get_parent().get_parent(), "_inquisition_progress"))
	start_game()

func start_game():
	$Timer2.start()

func _process(_delta):
	distance = int(abs(get_parent().get_parent().get_node("Units/necromancer").position.x - camera.limit_right_fix) / 20)
	if safe_time == 1:
		emit_signal("inquisition_move", max(max((percentage() -0.5), 0) * speed_inquisition * (1 / (((upgrade.buff_slow_inqui / 2) + 1))),0))
	if safe_time == 0 and distance > 50:
		safe_time = 1
		$Timer.start()
	$distance.text = str(distance) + "m"

func _on_timer_timeout():
	if (global.skipped == 0 and tutodone == 0 and distance < 20):
		get_node("../Label/Timer").start()
		get_node("../Label").show()
		tutodone = 1
	var tween = create_tween()
	target_value = $progress.value
	if score % 200 == 0:
		scaling += 1
	if score % 60 == 0:
		difficulty += scaling
	if score % 25 == 0:
		inquisition_army += difficulty
	if score % 5 == 0:
		fight()
	target_value = inquisition_army
	if safe_time == 1:
		score += 1
	full_army_count()
	update_score()
	update_inquisition(target_value)
	speed_inquisition_set()
	tween.tween_property($progress, "max_value", full_army, 0.3)
	divider()
	print("Debug")
	print("Percentage:" + str(percentage()))
	print("max_speed:" + str(max_speed))
	print("Speed inquisition:" + str(speed_inquisition))
	print("Difficulty:" + str(difficulty))
	if $progress.value == $progress.max_value or $progress.value == 0:
		$progress/Divider/Divider.hide()
	else:
		$progress/Divider/Divider.show()

func divider():
	var tween = create_tween()
	tween.tween_property($progress/Divider, "position", Vector2(500 - percentage() * 500 , -11), 0.3)

func fight():
	var rounded = int(difficulty / 2.0)
	if inquisition_army > rounded and undead_army > rounded:
		inquisition_army -= rounded
		undead_army -= rounded

func speed_inquisition_set():
	max_speed = (1 + (scaling * (1))) 
	if (speed_inquisition < max_speed):
		if (percentage() > 0.5):
			speed_inquisition += 0.03 + (scaling * 0.01)
		else:
			speed_inquisition -= 0.03
			speed_inquisition = max(speed_inquisition, 0)

func update_inquisition(target_v):
	var tween = create_tween()
	tween.tween_property($progress, "value", target_v, 0.3)
	
func to_war(nbr):
	if (nbr):
		undead_army += 1
	else:
		undead_army += 1
	speed_inquisition -= max((0.1) - (scaling * 0.01), 0)
	speed_inquisition = max(speed_inquisition, 0)
	full_army_count()

func full_army_count():
	full_army = inquisition_army + undead_army
	
func percentage():
	full_army_count()
	var percent = float(inquisition_army) / float(full_army)
	return (percent)
	
func update_score():
	$Score/Score.text = str(score)
	$progress/Undead_Score.text = str(undead_army)
	$progress/Inquisition_Score.text = str(inquisition_army)


func _on_inquisition_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouse \
	and event.is_action_pressed("leftclick"):
		camera.position.x = camera.limit_right_fix


func _on_mute_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouse \
	and event.is_action_pressed("leftclick"):
		if muted:
			$Mute/Mute.play("listen")
		else:
			$Mute/Mute.play("muted")
		toggle_mute_all()
			
func toggle_mute_all():
	muted = !muted
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), self.muted)


func _on_timer_2_timeout():
	if safe_time == 0:
		safe_time = 1
		$Timer.start()


func _on_timer_timeoutTUTO():
	get_node("../Label").hide()
