extends Area2D

const BOUNCE_FORCE = -3000.0  # Force applied to bounce the player

@onready var animated_sprite := $AnimatedSprite2D  # Reference to the AnimatedSprite2D node
@onready var bounce_sound := $BounceSound  # Reference to the AudioStreamPlayer2D node

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":  # Replace "Player" with your player's name
		bounce_player(body)

# Function to bounce the player
func bounce_player(player: Node2D):
	player.velocity.y = BOUNCE_FORCE
	animated_sprite.play("bounce")  # Play the bounce animation
	bounce_sound.play()  # Play the bounce sound effect
	await animated_sprite.animation_finished  # Wait for the animation to finish
	animated_sprite.play("default")  # Reset to the default animation
