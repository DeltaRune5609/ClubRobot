extends CharacterBody2D

const SPEED = 100.0  # Movement speed of the enemy
const BOUNCE_VELOCITY = -300.0  # Velocity when bouncing up
const GRAVITY = 500.0  # Gravity applied to the enemy

var direction := -1  # -1 for left, 1 for right
var is_player_on_top := false  # Track if the player is standing on the enemy
var is_squished := false  # Track if the enemy is squished

@onready var animated_sprite := $AnimatedSprite2D  # Reference to the AnimatedSprite2D node

func _physics_process(delta: float) -> void:
	if is_squished:
		return  # Stop all movement and logic if the enemy is squished

	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Move the enemy horizontally
	velocity.x = direction * SPEED
	move_and_slide()

	# Bounce back up when standing on the floor
	if is_on_floor():
		velocity.y = BOUNCE_VELOCITY

	# Check for boundaries (e.g., walls or edges)
	if is_on_wall():
		direction *= -1  # Reverse direction when hitting a wall

	# Handle player standing on the enemy
	if is_player_on_top and not is_squished:
		squish_enemy()

# Function to handle squishing the enemy
func squish_enemy():
	is_squished = true
	velocity = Vector2.ZERO  # Stop all movement
	animated_sprite.play("squish")  # Play the squish animation
	await animated_sprite.animation_finished  # Wait for the animation to finish
	queue_free()  # Delete the enemy after the animation

# Detect if the player is standing on the enemy
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":  # Replace "Player" with your player's name
		is_player_on_top = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":  # Replace "Player" with your player's name
		is_player_on_top = false
