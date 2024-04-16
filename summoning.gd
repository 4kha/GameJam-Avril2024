extends Area2D
@onready var upgrade = get_tree().get_root().get_node("./main/Upgrade")
var end = 0
var timer_duration = 6

func _ready():
	var value = (1 + (upgrade.buff_spawn_further * 0.5))
	scale = Vector2(value, value)
	$AnimatedSprite2D.play()
	$AudioStreamPlayer2D.play()
	$Timer.wait_time = timer_duration + upgrade.buff_longer_aoe * 3
	$Timer.start()

func _process(_delta):
	if end == 1:
		queue_free()

func _on_timer_timeout():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
	await tween.finished
	end = 1
