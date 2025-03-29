extends CharacterBody2D

class_name drillblock

const SPEED = 300
const JUMP_VELOCITY = -800.0  # Increased jump velocity for a more noticeable jump!!!
const GRAVITY = 2500.0
const PUSH_AWAY_FORCE = 2500.0  # Force to push the enemy away from the player
var direction = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead := false  
var health := 1

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
	if area.name == "laser" or (area.name == "player" and area.get_parent().is_dashing):
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
	animatedsprite.animation = "death"
	animatedsprite.play()
	# Disable collisions
	collision_shape_2d.set_deferred("disabled", true)

	bounce_sound.play()

	# Ensure the player reference is valid
	if player == null:
		player = get_tree().get_root().find_child("player", true, false)
		if player == null:
			return
			
	queue_free()
	#insert break animation here if necessary @boxthings2
