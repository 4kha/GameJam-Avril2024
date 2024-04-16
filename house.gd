extends StaticBody2D
const SHAKE_STRENGHT = 2
const SPAWN_FILL_RATE = 7
var max_life = 25
var current_life 
var units = 0
var destroyed = 0
var spawning = 0
var spawning_magic = 0
var house_zombie = 4
var shaking = 0
var origin
var spawn_max = 1
@onready var bar = $ProgressBar
@onready var timer = $Timer
@onready var unit = preload("res://squeleton.tscn")
@onready var upgrade = get_tree().get_root().get_node("./main/Upgrade")

# Called when the node enters the scene tree for the first time.
	
func _ready():
	add_to_group("house")
	current_life = max_life
	bar.max_value = max_life
	bar.hide()
	z_index = int(position.y + 33)
	$Smoke.hide()
	$magic.hide()
	$magic.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	bar.value = current_life
	if current_life <= 0:
		if destroyed == 0:
			$AudioStreamPlayer2D.play()
			houseDestroyed()
		elif destroyed == 1:
			for i in (spawn_max + upgrade.buff_spawn_more):
				spawn_unit(Vector2(position.x + 32, position.y + 32))
			house_zombie -= 1
			bar.value = max_life
			current_life = max_life
			if house_zombie == 0:
				destroyed = 2
				$AnimatedSprite2D.hide()
				$magic.hide()
				$Smoke.visible = true
				$Smoke.play()
	if shaking > 0:
		shaking -= 1
		$AnimatedSprite2D.offset = Randshake()
		if shaking == 0:
			$AnimatedSprite2D.offset = Vector2(0,0)

func _on_damage_area_body_entered(body):
	if body.is_in_group("squeleton"):
		units += 1
		startAttack()
	elif "necromancer" in body.name:
		spawning = 1
		if destroyed == 1:
			startAttack()
			$magic.show()
			$AudioStreamPlayer2D3.play()
			
func _on_damage_area_body_exited(body):
	if body.is_in_group("squeleton") \
	and destroyed == 0:
		units -= 1
		if units <= 0:
			timer.stop()
	elif "necromancer" in body.name:
		spawning = 0
		if destroyed == 1 and spawning_magic == 0:
			timer.stop()
			$magic.hide()

func _on_timer_timeout():
	damage()
	
func damage():
	if destroyed == 0:
		current_life -= (units) * (1 + upgrade.buff_skeleton_damage)
		bar_damage()
		shaking = 10
		$AudioStreamPlayer2D2.play()
	elif (spawning == 1 or spawning_magic == 1) \
	and destroyed == 1:
		if $magic.visible == false and spawning_magic == 0:
			$magic.show()
			$AudioStreamPlayer2D3.play()
		elif spawning_magic == 1:
			$magic.hide()
		current_life -= SPAWN_FILL_RATE + (upgrade.buff_spawn_faster * 3)
		bar_damage()

func bar_damage():
		if current_life > 0:
			bar.show()
		var tween = create_tween()
		tween.tween_property(bar, "value", current_life, (0.5)).set_trans(Tween.TRANS_LINEAR)

func startAttack():
	timer.start()

func houseDestroyed():
	bar.hide()
	$AnimatedSprite2D.play("destroyed")
	destroyed = 1
	bar.value = max_life
	current_life = max_life
	
func spawn_unit(pos):
	var tween = create_tween()
	var unitPath = get_tree().get_root().get_node("main/Units")
	var worldPath = get_tree().get_root().get_node("main")
	var unit1 = unit.instantiate()
	var rand = float(randf_range(-PI, PI)) 
	var target = Vector2(pos.x + (cos(rand) * 100), pos.y + (sin(rand) * 70))
	unit1.modulate = Color(1, 1, 1, 0)
	unit1.position = pos
	unitPath.add_child(unit1)
	unit1.target = target
	unit1.jump_out()
	tween.tween_property(unit1, "modulate", Color(1, 1, 1, 1), 0.5)
	worldPath.get_unit()
	
func Randshake():
	return (Vector2(randf_range(-1, 1) * SHAKE_STRENGHT, randf_range(-1, 1) * SHAKE_STRENGHT))


func _on_smoke_animation_finished():
	remove_from_group("house")
	get_parent().get_parent().get_house()
	queue_free()


func _on_spellhitbox_area_entered(area):
	if area.is_in_group("fireball"):
		if destroyed == 0:
			current_life -= area.damage
			area.explode()
			shaking = 10
			bar_damage()
			if current_life <= 0 and spawning_magic == 1:
				startAttack()
	if area.is_in_group("summon"):
		spawning_magic = 1
		if destroyed == 1:
			startAttack()
			bar_damage()

func _on_spellhitbox_area_exited(area):
	if area.is_in_group("summon"):
		if spawning == 0:
			$Timer.stop()
		spawning_magic = 0
