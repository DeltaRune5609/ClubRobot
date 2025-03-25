extends StaticBody2D

const BOUNCE_FORCE = -600.0  # Force applied to bounce the player

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		bounce_player(body)

func bounce_player(player: Node2D):
	player.velocity.y = BOUNCE_FORCE
