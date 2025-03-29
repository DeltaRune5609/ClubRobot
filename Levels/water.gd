extends Area2D

@export var water_drag := 0.9  # Higher = more resistance
@export var water_gravity_scale := 0.6 
@export var jump_reduction := 0.7  # Jump strength multiplier

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.in_water = true
		body.water_drag = water_drag
		body.water_gravity_scale = water_gravity_scale

func _on_body_exited(body):
	if body.is_in_group("player"):
		body.in_water = false
