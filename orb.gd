extends Area2D

var velocity: Vector2 = Vector2.ZERO
@export var heal_value: float = 1.0
@export var initial_force: float = 200.0
@export var homing_speed: float = 100.0
@export var homing_delay: float = 0.5
@export var bounce_factor := 0.3
@export var direction := Vector2.ZERO

var is_grounded := false
var target: Node2D  # Will reference the player
var can_home: bool = false
var x = -0.5
var frame = 0
<<<<<<< HEAD

func _ready():
	# Set a random direction when spawned
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	# Apply initial force in the random direction
	velocity = direction * initial_force
	
	# Enable homing after delay
	$Timer.wait_time = 2
	$Timer.start()
	body_entered.connect(_on_body_entered)

=======
func _ready():
	# Initial burst in random direction
	velocity.x *= randf_range(-1, 1)
	velocity = direction * initial_force
	
	# Enable homing after delay
	$Timer.wait_time = homing_delay
	$Timer.start()
	body_entered.connect(_on_body_entered)

# In HealingOrb.gd
>>>>>>> 890cd3cde60dde59e0e0c8076f11dca884135f8a
func _physics_process(delta: float):
	if frame < 10:
		velocity.y += gravity * delta
		position += velocity * delta
		rotation = velocity.angle()
		frame += 1
<<<<<<< HEAD

=======
	
>>>>>>> 890cd3cde60dde59e0e0c8076f11dca884135f8a
func _on_timer_timeout():
	can_home = true

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		# Disable collision before queue_free
		$CollisionShape2D.set_deferred("disabled", true)
		body.heal()
		queue_free()
