extends CharacterBody2D

const SPEED = 300
const JUMP_VELOCITY = -800.0  # Increased jump velocity for a more noticeable jump!!!
const GRAVITY = 2500.0
const PUSH_AWAY_FORCE = 2500.0  # Force to push the enemy away from the player
var direction = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead := false  
var health := 2 

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animatedsprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var bounce_sound: AudioStreamPlayer2D = $BounceSound  # Reference to the bounce sound node :hdheavysob:
@onready var area2d: Area2D = $Area2D

var player: CharacterBody2D = null

func _ready():
	animatedsprite.play("default")
	# Find the player node dynamically
	player = get_tree().get_root().find_child("player", true, false)

	# Connect the Area2D signals
	area2d.connect("body_entered", Callable(self, "_on_area2d_body_entered"))
	area2d.connect("area_entered", Callable(self, "_on_area2d_area_entered"))

func _physics_process(delta):
	if is_dead:
		velocity.y += gravity * delta
		velocity.x = direction * SPEED
		move_and_slide()
		return 

	if ray_cast_right.is_colliding():
		direction = -1
		animatedsprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animatedsprite.flip_h = false

	velocity.y += gravity * delta
	velocity.x = direction * SPEED * 0
	move_and_slide()

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.name == "player":
		die()

func _on_area2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		die()

func _on_area2d_area_entered(area: Area2D) -> void:
	# Check if the area is the laser or the player's dash
	if area.name == "Laser" or (area.name == "Player" and area.get_parent().is_dashing):
		take_damage(1, area.global_position)  # Deal 1 damage to the enemy

func take_damage(damage: int, _attacker_position: Vector2):
	if is_dead:
		return  # Prevent taking damage if already dead

	health -= damage
	if health <= 0:
		die()
	else:
		pass

func die():
	if is_dead:
		return  # Prevent multiple calls to die()

	is_dead = true  # Mark the enemy as dead

	# Disable collisions
	collision_shape_2d.set_deferred("disabled", true)

	bounce_sound.play()

	# Ensure the player reference is valid
	if player == null:
		player = get_tree().get_root().find_child("player", true, false)
		if player == null:
			return

	# Calculate the direction to the player
	var player_direction = (player.global_position - global_position).normalized()

	# Rotate the enemy to face the player
	animatedsprite.rotation = player_direction.angle()

	# Push the enemy away from the player
	velocity.y = JUMP_VELOCITY  # Apply upward velocity
	velocity.x = -player_direction.x * PUSH_AWAY_FORCE  # Push horizontally away from the player

	# Wait for the enemy to go off-screen
	await get_tree().create_timer(5.0).timeout 

	# Delete the enemy
	queue_free()

	# Wait for a slight delay before deleting the Area2D and its children
	await get_tree().create_timer(0.5).timeout 
	if is_instance_valid(area2d):
		area2d.queue_free()
