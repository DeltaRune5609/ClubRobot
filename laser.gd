extends Area2D

@export var speed := 2000.0
@export var direction := Vector2.RIGHT

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
<<<<<<< HEAD
		body.take_damage(2, global_position)
	queue_free()
	if body.is_in_group("player") and body.has_method("take_damage"):
		var damage: int = 1  # Amount of damage this object deals
		var knockback_force: Vector2 = Vector2(500, -300)  # Knockback force when hitting the player
		var knockback_direction = (body.global_position - global_position).normalized()
		body.take_damage(damage, knockback_direction * knockback_force)
=======
		body.take_damage(1, global_position)
	queue_free()
>>>>>>> 890cd3cde60dde59e0e0c8076f11dca884135f8a

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
