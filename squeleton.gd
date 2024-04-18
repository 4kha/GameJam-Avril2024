extends CharacterBody2D

@export var selected = false
@export var beginning = false
@onready var box = get_node("box")
@onready var info = get_parent().get_parent().get_node("UI/Information")
@onready var upgrade = get_tree().get_root().get_node("./main/Upgrade")
@onready var target = position
@onready var house 
var in_model = false
var follow_cursor = false
const SPEED = 50
var leaving = 0
var previous = null
const ATTACK = 1
var just_spawned = 0
signal despawn

func _ready():
	add_to_group("unit")
	add_to_group("squeleton")
	set_selected(selected)
	$AnimatedSprite2D.play()
	if beginning == false:
		$AudioStreamPlayer2D.play()

func get_attack():
	return (ATTACK + upgrade.buff_skeleton_damage)

func set_selected(value):
	selected = value
	box.visible = value
	
func _input(event):
	if event.is_action_pressed("rightclick"):
		follow_cursor = true
	if event.is_action_released("rightclick"):
		follow_cursor = false
	if event.is_action_pressed("leftclick") \
	and in_model == true:
			get_parent().get_parent().clear_selection()
			set_selected(true)
	if event is InputEventMouseButton \
	and event.is_action_pressed("leftclick") \
	and event.double_click \
	and in_model == true:
		get_parent().get_parent().get_all_army()

func _physics_process(_delta):
	z_index = int(position.y) + 12
	if just_spawned == 0:
		if leaving == 1:
			target.x = position.x + 2000 
			leaving = 0
		if follow_cursor == true:
			if selected:
				target = get_global_mouse_position()
		velocity = position.direction_to(target).normalized() * (SPEED + (upgrade.buff_skeleton_fast + 15))
		if position.distance_to(target) > 20:
			move_and_slide()
			$Timer.start()
		else:
			$Timer.stop()
	else:
		velocity = position.direction_to(target) * (SPEED + (upgrade.buff_skeleton_fast + 1))
		if position.distance_to(target) > 20:
			move_and_slide()
		else:
			just_spawned = 0;
			$CollisionShape2D.disabled = false
	$AnimatedSprite2D.flip_h = velocity.x < 0
	if velocity.x < 20 and velocity.y < 20:
		$AnimatedSprite2D.play("default")
	else:
		$AnimatedSprite2D.play("walk")


func _on_timer_timeout():
	if previous == null:
		previous = position
	else:
		if abs(previous.x - position.x) <= SPEED * 10 \
		and abs(previous.y - position.y) <= SPEED * 10 :
			target = position
			$Timer.stop()
		else:
			previous = position

func jump_out():
	var _start = position
	just_spawned = 1
	$CollisionShape2D.disabled = true


func _on_clickbox_mouse_entered():
	in_model = true

func _on_clickbox_mouse_exited():
	in_model = false
	
func teleported():
	info.to_war(1)
	set_selected(false)
	remove_from_group("squeleton")
	remove_from_group("unit")
	queue_free()
	get_parent().get_parent().get_unit()
