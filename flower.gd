extends Area2D
var sprite = ["flower1", "flower2", "flower3", "flower4"]

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play(sprite[randi_range(0, 3)])
	add_to_group("flower")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
