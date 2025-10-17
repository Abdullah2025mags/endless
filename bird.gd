#extends Area2D
## Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#position.x -= get_parent().speed * 0.3
	#
extends Area2D

# The obstacle's base speed (editable in editor)
@export var speed: float = 150.0

# Optional global multiplier (if you want game speed-up later)
@export var speed_multiplier: float = 2.25

func _ready():
	pass

func _process(delta):
	# Move left at independent speed
	position.x -= speed * speed_multiplier * delta
