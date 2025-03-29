extends AnimatedSprite2D

# Reference to the player node
@onready var player := get_parent()

func _process(_delta: float) -> void:
	update_animation()

func update_animation():
	if player.is_hit:
		# Play the "hit" animation when the player is in the hit state
		play("hit")
		return  # Skip other animations while in the hit state

	if player.is_shooting:
		# Play the "shoot" animation when the player is shooting
		play("shoot")
		return  # Skip other animations while shooting

	if player.is_dashing:
		# Play the "dash" animation when the player is dashing
		play("dash")
		flip_h = player.last_tap_direction == -1  # Flip sprite based on dash direction
		return  # Skip other animations while dashing

	if player.is_ground_pounding:
		# Play the "drill" animation during the ground pound
		play("drill")
		return  # Skip other animations while ground pounding

	if player.is_wall_jump_chaining:
		# Play spin animation while in the wall jump state
		play("spin")
		flip_h = player.wall_direction == 1  # Flip sprite based on wall direction
	elif player.is_gliding:
		# Play glide animation and face the direction of movement
		play("glide")
		flip_h = player.velocity.x < 0  # Flip sprite if moving left
	else:
		if player.is_on_floor():
			if abs(player.velocity.x) > 10:  # Player is moving
				play("walk")
				flip_h = player.velocity.x < 0  # Flip sprite if moving left
			else:
				play("stand")  # Player is standing still
		else:
			if player.velocity.y < 0:
				play("jump")  # Player is moving upward (jumping)
			else:
				play("fall")  # Player is falling
