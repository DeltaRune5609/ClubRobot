extends CharacterBody2D

#Insert grabbing index

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.keys[0] == true:
		print('dead')
		queue_free()
	else:
		pass
