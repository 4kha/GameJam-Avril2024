extends Camera2D
const SCREENSIZE = 310
var mousePos = Vector2()
var mousePosGlobal = Vector2()
var start = Vector2()
var startV = Vector2()
var end = Vector2()
var endV = Vector2()
var isDragging = false
var limit_left_fix = -2000
var limit_right_fix = 1000
signal area_selected
signal start_move_selection
signal recenter
signal all_units
signal leave_east
signal spell1
signal spell2
signal spell3
signal avance
var spell1_cd_max = 15
var spell2_cd_max = 20
var spell3_cd_max = 30
var spell1_reset = 0
var spell2_reset = 0
var spell3_reset = 0

var spell1_cd = 0
var spell2_cd = 0
var spell3_cd = 0

#camera control
@export var SPEED = 15.0
@onready var main = get_parent().get_parent()
@onready var necromancer = get_parent().get_parent().get_node("Units/necromancer")
@onready var upgrade = get_tree().get_root().get_node("./main/Upgrade")

func _ready():
	draw_area(false)
	reset_over()
	connect("area_selected", Callable(main, "_on_area_selected"))
	connect("recenter", Callable(main, "_on_recenter"))
	connect("all_units", Callable(main, "get_all_army"))
	connect("leave_east", Callable(main, "_leave_east"))
	connect("avance", Callable(main, "_avance"))
	connect("spell1", Callable(necromancer, "_spell1"))
	connect("spell2", Callable(necromancer, "_spell2"))
	connect("spell3", Callable(necromancer, "_spell3"))

func _process(_delta):
	if Input.is_action_just_pressed("leftclick"):
		start = mousePosGlobal
		startV = mousePos
		isDragging = true
	if isDragging:
		end = mousePosGlobal
		endV = mousePos
		draw_area()
	if Input.is_action_just_released("leftclick"):
		if startV.distance_to(mousePos) > 20:
			end = mousePosGlobal
			endV = mousePos
			isDragging = false
			draw_area(false)
			emit_signal("area_selected", self)
		else:
			end = false
			isDragging = false
			draw_area(false)
	if Input.is_action_pressed("left"):
		position.x -= SPEED
	if Input.is_action_pressed("right"):
		position.x += SPEED
	if Input.is_action_pressed("focus_recenter"):
		emit_signal("recenter")
	if Input.is_action_pressed("quit"):
		pass
	if Input.is_action_pressed("Spell1"):
		cast_spell1()
	if Input.is_action_pressed("Spell2"):
		cast_spell2()
	if Input.is_action_pressed("Spell3"):
		cast_spell3()
	if abs(necromancer.position.x - limit_left_fix) < 720:
		limit_left_fix -= 10 
		emit_signal("avance")
	if position.x < limit_left_fix:
		position.x = limit_left_fix
	if position.x + SCREENSIZE > limit_right_fix:
		position.x = limit_right_fix - SCREENSIZE
	check_cd(spell1_cd, get_node("../Spell1/Label"), get_node("../Spell1/Sprite2D2"), 1)
	check_cd(spell2_cd, get_node("../Spell2/Label"), get_node("../Spell2/Sprite2D2"), 2)
	check_cd(spell3_cd, get_node("../Spell3/Label"), get_node("../Spell3/Sprite2D2"), 3)
	
func _input(event):
	if event is InputEventMouse:
		mousePos = event.position
		mousePosGlobal = get_parent().get_parent().get_global_mouse_position()

func draw_area(s = true):
	get_node("../Panel").size = Vector2(abs(startV.x - endV.x), abs(startV.y -endV.y))
	var pos = Vector2()
	pos.y = min(startV.y, endV.y)
	pos.x = min(startV.x, endV.x)
	get_node("../Panel").position = pos
	get_node("../Panel").size *= int(s)

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouse \
	and event.is_action_pressed("leftclick"):
		emit_signal("recenter")

func _on_army_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouse \
	and event.is_action_pressed("leftclick"):
		emit_signal("all_units")

func _on_leave_east_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouse \
	and (event.is_action_pressed("rightclick") \
	or event.is_action_pressed("leftclick")):
		emit_signal("leave_east")

func reset_over():
	if spell1_cd == 0:
		get_node("../Spell1/Sprite2D2").hide()
	if spell2_cd == 0:
		get_node("../Spell2/Sprite2D2").hide()
	if spell3_cd == 0:
		get_node("../Spell3/Sprite2D2").hide()

func _on_spell_1_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouse \
	and event.is_action_pressed("leftclick"):
		cast_spell1()

func _on_spell_2_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouse \
	and event.is_action_pressed("leftclick"):
		cast_spell2()

func _on_spell_3_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouse \
	and event.is_action_pressed("leftclick"):
		cast_spell3()
			
func cast_spell1():
	if spell1_cd == 0:
		reset_over()
		get_node("../Spell1/Sprite2D2").show()
		emit_signal("spell1")

func cast_spell2():
	if spell2_cd == 0:
		reset_over()
		get_node("../Spell2/Sprite2D2").show()
		emit_signal("spell2")

func _unhandled_input(event):
	if event is InputEventMouse \
	and event.is_action_pressed("leftclick"):
		main.clear_selection()

func cast_spell3():
	if spell3_cd == 0:
		reset_over()
		get_node("../Spell3/Sprite2D2").show()
		emit_signal("spell3")

func casted(spell_casted):
	if spell_casted == 1:
		spell1_cd = spell1_cd_max - min(upgrade.buff_cdr_flame * 3, 12)
		spell1_reset = 0
	elif spell_casted == 2:
		spell2_cd = spell2_cd_max - min(upgrade.buff_cdr_tp * 4, 15)
		spell2_reset = 0
	elif spell_casted == 3:
		spell3_cd = spell3_cd_max - min(upgrade.buff_cdr_summon * 5, 25)
		spell3_reset = 0
	get_node("../Timer").start()


func _on_timer_timeout():
	if spell1_cd > 0:
		spell1_cd -= 1
	if spell2_cd > 0:
		spell2_cd -= 1
	if spell3_cd > 0:
		spell3_cd -= 1
		
func check_cd(cdr, label, grey, nbr):
	if cdr == 0:
		label.hide()
		if nbr == 1 and spell1_reset == 0:
			grey.hide()
			spell1_reset = 1
		if nbr == 2 and spell2_reset == 0:
			grey.hide()
			spell2_reset = 1
		if nbr == 3 and spell3_reset == 0:
			grey.hide()
			spell3_reset = 1
	else:
		label.show()
		label.text = str(cdr)
		grey.show()
