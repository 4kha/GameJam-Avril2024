extends CharacterBody2D

@onready var upgrade = get_tree().get_root().get_node("./main/Upgrade")
@export var selected = false
@onready var box = get_node("box")
@onready var target = position
@onready var hud = get_parent().get_parent().get_node("./UI/Camera2D")
@onready var fireball = preload("res://fireball.tscn")
@onready var summon = preload("res://summoning.tscn")
@onready var teleport = preload("res://teleport.tscn")

const FIREBALL_SPEED = 800
const SPEED = 50 
var spell = 0

var follow_cursor = false
const attack = 5

func _ready():
	add_to_group("player")
	$AnimatedSprite2D.play()
	set_selected(selected)
	
func set_selected(value):
	selected = value
	box.visible = value
	
func _input(event):
	if event.is_action_pressed("rightclick"):
		follow_cursor = true
		hud.reset_over()
	if event.is_action_released("rightclick"):
		follow_cursor = false
	if event.is_action_pressed("leftclick") and spell > 0:
		if spell == 1:
			cast_spell1(get_global_mouse_position())
		elif spell == 2:
			cast_spell2(get_global_mouse_position())
		elif spell == 3:
			cast_spell3(get_global_mouse_position())
		hud.casted(spell)
		spell = 0
		
func _physics_process(_delta):
	z_index = int(position.y -10)
	if follow_cursor == true:
		if selected:
			target = get_global_mouse_position()
	velocity = position.direction_to(target).normalized() * (SPEED + (upgrade.buff_fast_necro * 30))
	if position.distance_to(target) > 10:
		move_and_slide()
	else:
		pass
	$AnimatedSprite2D.flip_h = velocity.x < 0

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouse \
	and event.is_action_pressed("leftclick"):
		get_parent().get_parent().clear_selection()
		set_selected(!selected)
		
func _spell1():
	spell = 1
	
func _spell2():
	spell = 2
	
func _spell3():
	spell = 3
	
func cast_spell1(pos):
	var tween = create_tween()
	var fire = fireball.instantiate()
	fire.position = position
	var target_spell = (pos - position).normalized() * FIREBALL_SPEED
	target_spell = target_spell + position
	fire.rotation = fire.get_angle_to(target_spell)
	fire.add_to_group("fireball")
	tween.tween_property(fire, "position", target_spell, 0.5)
	get_parent().add_child(fire)
	
	
func cast_spell2(pos):
	var tele = teleport.instantiate()
	tele.position = pos
	tele.add_to_group("teleport")
	get_parent().add_child(tele)


func cast_spell3(pos):
	var sum = summon.instantiate()
	sum.position = pos
	sum.add_to_group("summon")
	get_parent().add_child(sum)

func teleported():
	position.x -= 600
	target = position
