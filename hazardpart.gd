extends Area2D

@export var damage: int = 1  # Amount of damage this object deals
@export var knockback_force: Vector2 = Vector2(500, -300)  # Knockback force when hitting the player

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node2D):
	if body.name == "player" and body.has_method("take_damage"):
		# Calculate the direction of knockback
		var knockback_direction = (body.global_position - global_position).normalized()
		# Apply knockback and damage to the player
		body.take_damage(damage, knockback_direction * knockback_force)
