extends Node2D

@onready var progress = $progress
@onready var camera = get_node("../Camera2D")
@onready var upgrade = get_tree().get_root().get_node("./main/Upgrade")
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

func _ready():
	$progress.max_value = 4
	$progress.value = 2
	$progress/Divider.position.x = 0
	$progress/Divider/Divider.hide()
	connect("inquisition_move", Callable(get_parent().get_parent(), "_inquisition_progress"))
	start_game()

func start_game():
	$Timer.start()

func _process(_delta):
	emit_signal("inquisition_move", (percentage() -0.5) * speed_inquisition)
	$distance.text = str(int(abs(get_parent().get_parent().get_node("Units/necromancer").position.x - camera.limit_right_fix) / 20)) + "m"

func _on_timer_timeout():
	var tween = create_tween()
	target_value = $progress.value
	if score % 60 == 0:
		difficulty += 1
	if score % 20 == 0:
		inquisition_army += difficulty
	target_value = inquisition_army
	score += 1
	full_army_count()
	update_score()
	update_inquisition(target_value)
	speed_inquisition_change()
	tween.tween_property($progress, "max_value", full_army, 0.3)
	divider()
	if $progress.value == $progress.max_value or $progress.value == 0:
		$progress/Divider/Divider.hide()
	else:
		$progress/Divider/Divider.show()

func speed_inquisition_change():
	if (percentage() >= 0.5):
		speed_inquisition += 0.01 * difficulty * (1 / float(upgrade.buff_slow_inqui + 1))
	else:
		speed_inquisition -= 0.01

func divider():
	var tween = create_tween()
	tween.tween_property($progress/Divider, "position", Vector2(500 - percentage() * 500 , -11), 0.3)

func update_inquisition(target_v):
	var tween = create_tween()
	tween.tween_property($progress, "value", target_v, 0.3)
	
func to_war(nbr):
	if (nbr):
		undead_army += 1
	else:
		undead_army += 1
	speed_inquisition -= (0.1)
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
