extends Node2D
@onready var global = get_node("/root/Score")

var units = []
var lock = false
var chunck = 1
var distance_made = 0
var house_delay = 0
var switch = 0
var houselist = []
var flowerlist = []
var last_library = 0
@onready var necromancer = get_node("Units/necromancer")
@onready var house = preload("res://house.tscn")
@onready var tower = preload("res://tower.tscn")
@onready var library = preload("res://library.tscn")
@onready var flower = preload("res://flower.tscn")

func _ready():
	$fade.show()
	if (global.skipped == 1):
		$Intro.hide()
	else:
		$Intro/Timer.start()
	$AnimationPlayer.play("fade")
	spawn_x_house(14)
	units = get_tree().get_nodes_in_group("unit")
	
func _process(_delta):
	if lock:
		recenter()
	if house_delay > 100:
		house_delay -= 100
		spawn_random_house()
		chunck += 1
	if switch == 1:
		switch_scene()

func spawn_random_house():
	var n = which_house()
	if n == 0:
		spawn_house(valid_random())
	if n == 1:
		spawn_tower(valid_random())
	if n == 2: 
		spawn_library(valid_random())
		last_library = 0
	spawn_flower(valid_random_flower())
	
func get_unit():
	units = null
	units = get_tree().get_nodes_in_group("unit")

func get_house():
	houselist = null
	houselist = get_tree().get_nodes_in_group("house")

func get_flower():
	houselist = null
	houselist = get_tree().get_nodes_in_group("flower")

func _avance():
	house_delay += 10

func _on_area_selected(object):
	var start = object.start
	var end = object.end
	var area = []
	area.append(Vector2(min(start.x, end.x), min(start.y, end.y)))
	area.append(Vector2(max(start.x, end.x), max(start.y, end.y)))
	var ut = get_units_in_area(area)
	clear_selection()
	for unit in ut:
		unit.set_selected(!unit.selected)

func get_units_in_area(area):
	var u = []
	for unit in units:
		if (unit.position.x +16 > area[0].x) and (unit.position.x + 16 < area[1].x):
			if (unit.position.y +16 > area[0].y) and (unit.position.y +16 < area[1].y):
				u.append(unit)
	return u

func _on_recenter():
	if (necromancer.selected == true):
		clear_selection()
		necromancer.set_selected(true)
		recenter()
	else:
		clear_selection()
		necromancer.set_selected(true)

func get_all_army():
	for unit in units:
		unit.set_selected(true)
	necromancer.set_selected(false)
	
func _leave_east():
	necromancer.set_selected(false)
	var leaving = get_selected()
	for unit in leaving:
		unit.leaving = 1;
		unit.selected = false

func get_selected():
	var ret = []
	for unit in units:
		if unit.selected == true:
			ret.append(unit)
	return ret


func clear_selection():
	for unit in units:
		unit.set_selected(false)

func recenter():
	$UI/Camera2D.position.x = necromancer.position.x


func _on_play_area_body_exited(body):
	if body.is_in_group("squeleton"):
		$UI/Information.to_war(0)
		body.set_selected(false)
		body.remove_from_group("squeleton")
		body.remove_from_group("unit")
		get_unit()
		$Units/Sent.play()
		body.queue_free()
	elif body.is_in_group("house"):
		body.remove_from_group("house")
		get_house()
		body.queue_free()
	elif body.is_in_group("player"):
		for unit in units:
			unit.queue_free()
		switch = 1;
	elif body.is_in_group("flower"):
		body.remove_from_group("flower")
		get_house()
		body.queue_free()
	
func _inquisition_progress(move):
	distance_made += move
	$UI/Camera2D.limit_left_fix -= move
	$UI/Camera2D.limit_right_fix -= move
	if distance_made > 1:
		$playArea/area.position.x -= distance_made
		$Polygon2D.position.x -= distance_made
		distance_made = 0
	house_delay += move

func spawn_x_house(nbr):

	for i in nbr:
		chunck += 1
		last_library += 1
		if (last_library > 7):
			spawn_library(valid_random())
			last_library = 0
		else:
			spawn_random_house()
		
func check_house_proximity(pos):
	for h in houselist:
		if pos.distance_to(Vector2((h.position.x),(h.position.y))) < 100:
			return 1
		if pos.distance_to(Vector2((h.position.x + 32),(h.position.y + 32))) < 100:
			return 1
	return 0
	
func check_flower_proximity(pos):
	for f in flowerlist:
		if pos.distance_to(Vector2((f.position.x + 10),(f.position.y + 10))) < 120:
			return 1
	return 0
	
func valid_random_flower():
	var random = get_random_flower_coordinate()
	while check_flower_proximity(random):
		random = get_random_flower_coordinate()
	return random
	
func valid_random():
	get_house()
	var random = get_random_coordinate()
	while check_house_proximity(random):
		random = get_random_coordinate()
	return random

func get_random_flower_coordinate():
	return Vector2(randf_range(-200 * chunck, -200 * chunck + 600), randf_range(150, 375))
	
func get_random_coordinate():
	return Vector2(randf_range(-200 * chunck, -200 * chunck + 600), randf_range(150, 375))

func spawn_flower(pos):
	var flower1 = flower.instantiate()
	flower1.position = pos
	$Houses.add_child(flower1)
	get_flower()

func spawn_house(pos):
	var house1 = house.instantiate()
	house1.position = pos
	$Houses.add_child(house1) 
	get_house()
	
func spawn_tower(pos):
	var tower1 = tower.instantiate()
	tower1.position = pos
	$Houses.add_child(tower1) 
	get_house()
	
func spawn_library(pos):
	var library1 = library.instantiate()
	library1.position = pos
	$Houses.add_child(library1) 
	get_house()
	
func _input(event):
	if event is InputEventMouse \
	and event.is_action_pressed("leftclick"):
		pass
		
func switch_scene():
	global.global_score = $UI/Information.score
	get_tree().change_scene_to_file("res://game_over.tscn")


func _on_timer_timeout():
	var tween = create_tween()
	tween.tween_property($Intro, "modulate", Color(1,1,1,0), 0.5)
	
func get_rand_weight(n1, n2, n3):
	var dice = []
	for i in n1:
		dice.append(0)
	for i in n2:
		dice.append(1)
	for i in n3:
		dice.append(2)
	return dice
	
func which_house():
	var dice = get_rand_weight(10, 2, 4)
	var rand = randi_range(0, dice.size() - 1)
	rand = dice[rand]
	return(rand)
