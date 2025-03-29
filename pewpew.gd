extends Area2D

# Constants
const SPEED = 1000.0  # Speed of the laser
const DAMAGE = 1      # Damage dealt to enemies

# Variables
var direction := Vector2.LEFT  # Direction the laser moves in

# Node references
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# Debug: Confirm the laser is created
	print("Laser created at:", global_position)

	# Set the laser's rotation based on its direction
	rotation = direction.angle()
	print("Laser rotation set to:", rotation)

	# Connect the body_entered signal to handle collisions
	if connect("body_entered", Callable(self, "_on_body_entered")) == OK:
		print("body_entered signal connected successfully")
	else:
		print("Failed to connect body_entered signal")

func _physics_process(delta: float) -> void:
	# Debug: Track laser movement
	var previous_position = global_position  # Use global_position for accurate tracking
	global_position += direction * SPEED * delta
	print("Laser moved from:", previous_position, "to:", global_position)

	# Remove the laser if it goes off-screen
	if not is_on_screen():
		print("Laser went off-screen at:", global_position)
		queue_free()

func _on_body_entered(body: Node) -> void:
	# Debug: Log the collision
	print("Laser collided with:", body.name)

	# Ignore collisions with the player or Background tileset
	if body.is_in_group("player") or body.is_in_group("background"):
		print("Ignoring collision with player or background")
		return

	# Debug: Check if the body has the 'take_damage' method
	if body.has_method("take_damage"):
		print("Body has take_damage method. Dealing damage.")
		body.take_damage(DAMAGE, global_position)
	else:
		print("Body does not have take_damage method")

	# Debug: Confirm the laser is being removed
	print("Removing laser after collision")
	queue_free()

func is_on_screen() -> bool:
	# Check if the laser is within the viewport
	var viewport_rect = get_viewport_rect()
	return viewport_rect.has_point(global_position)
