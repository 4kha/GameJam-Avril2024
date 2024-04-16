extends Area2D
@onready var upgrade = get_tree().get_root().get_node("./main/Upgrade")
var end = 0

func _ready():
	var value = (1.5 + (upgrade.buff_bigger_tp * 0.5))
	scale = Vector2(value, value)
	$AnimatedSprite2D.play()
	$Timer.start()
	


func _process(_delta):
	if end == 1:
		queue_free()

func _on_timer_timeout():
	var body = get_overlapping_bodies()
	for u in body:
		if u.is_in_group("squeleton"):
			u.teleported()
	end = 1
