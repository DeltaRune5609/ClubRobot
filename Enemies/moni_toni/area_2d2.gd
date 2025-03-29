extends Area2D

const BOUNCE_FORCE = -1000.0  # Force applied to bounce the player

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":  # Ensure this matches the player's name
		await get_tree().create_timer(0.05).timeout  # Add a slight delay (0.2 seconds)
		bounce_player(body)

# Function to bounce the player
func bounce_player(player: Node2D):
	if player.has_method("set_velocity"):  # Ensure the player has a velocity property
		player.velocity.y = BOUNCE_FORCE
	else:
		pass
