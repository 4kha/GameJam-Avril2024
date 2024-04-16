extends Area2D
@onready var upgrade = get_tree().get_root().get_node("./main/Upgrade")
var damage = 10
var end = 0
var free = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("fireball")
	$Fireball.play("default")
	$AudioStreamPlayer2D.play()
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	z_index = int(position.y)
	if free == 1:
		$CollisionShape2D.disabled = true
	if end == 1:
		queue_free()
		
func get_damage():
	return damage + (upgrade.buff_dmg_flame * 5)

func explode():
	$Fireball.hide()
	$AudioStreamPlayer2D2.play()
	$Timer.stop()
	free = 1

func _on_timer_timeout():
	$Fireball.hide()
	$AudioStreamPlayer2D2.play()
	free = 1

func _on_audio_stream_player_2d_2_finished():
	end = 1
