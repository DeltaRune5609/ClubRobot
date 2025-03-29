# Assuming this script is attached to the AnimatedSprite2D node or a parent node

# Get a reference to the AnimatedSprite2D node
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# Play the "default" animation
	animated_sprite.play("default")
