extends CharacterBody2D

signal laserbossdead

var SPEED = 300
const JUMP_VELOCITY = -800.0  # Increased jump velocity for a more noticeable jump!!!
const GRAVITY = 2500.0
const PUSH_AWAY_FORCE = 500.0  # Force to push the enemy away from the player
var direction = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead := false  
var health := 5

var times_dead = 0

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animatedsprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var bounce_sound: AudioStreamPlayer2D = $BounceSound  # Reference to the bounce sound node :hdheavysob:
@onready var area2d: Area2D = $Area2D
@onready var laser_scene = preload("res://Levels/pew.tscn")  # Updated to use the pew scene
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var laser_sound: AudioStreamPlayer2D = $LaserSound  # Reference to the LaserSound node



var player: CharacterBody2D = null
var attacking := 1
var attack := 0

#Copy paste ones frmo drill boss
var positions = {
	1: Vector2(-3261.53, 49.04311),
	2: Vector2(-281.6687, 49.04316),
	3: Vector2(-2179.836, 49.04312),
	4: Vector2(-1620.169, 49.04312)
}

func _ready():
	animatedsprite.play("default")
	player = get_tree().get_root().find_child("player", true, false)

	# Connect signals
	area2d.connect("body_entered", Callable(self, "_on_area2d_body_entered"))
	area2d.connect("area_entered", Callable(self, "_on_area2d_area_entered"))
	if Global.bosses[0] == true:
		queue_free()
	# Start dash timer
	attack_timer()

func attack_timer():
	await get_tree().create_timer(3).timeout  # Dash every 3 seconds
	attacking *= -1
	SPEED = 0 if attacking > 0 else 300
	await get_tree().create_timer(2).timeout  # Delay before moving again
	SPEED = 300
	attack_timer()  # Restart timer


func _physics_process(delta):
	if is_dead:
		velocity.y = 0
		return 

	if ray_cast_right.is_colliding():
		direction = -1
		animatedsprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animatedsprite.flip_h = false

	velocity.y += gravity * delta * 0
	
	think()

func think():
	var what := false
	animatedsprite.animation = "default"
	animatedsprite.play()
	if fmod(attack, 120) == 0:
		attacking = attacking * -1
		attack = 0
		what = true
	attack += 1
	if what == true and attacking > 0:
		#Insert pop up and shoot logic here
		var cool = positions[randi() % 4 + 1]
		global_position = Vector2(cool)
		for i in range(3):
			shoot_laser()
			await get_tree().create_timer(0.3).timeout
		direction = -1
		animatedsprite.flip_h = true
		for i in range(3):
			shoot_laser()
			await get_tree().create_timer(0.3).timeout
		direction = 1
		animatedsprite.flip_h = false
		pass

func _on_player_detector_body_entered(body: Node2D) -> void:
	if (body.name == "Player" and body.get_parent().is_dashing):
		var damage: int = 1  # Amount of damage this object deals
		var knockback_force: Vector2 = Vector2(500, -300)  # Knockback force when hitting the player
		var knockback_direction = (body.global_position - global_position).normalized()
		body.take_damage(damage, knockback_direction * knockback_force)
		
func _on_area2d_body_entered(body: Node2D) -> void:
	if (body.name == "Player" and body.get_parent().is_dashing):
		var damage: int = 1  # Amount of damage this object deals
		var knockback_force: Vector2 = Vector2(500, -300)  # Knockback force when hitting the player
		var knockback_direction = (body.global_position - global_position).normalized()
		body.take_damage(damage, knockback_direction * knockback_force)

func _on_area2d_area_entered(area: Area2D) -> void:
	# Check if the area is the laser or the player's dash
	if area.name == "Laser":
		take_damage(1, area.global_position)  # Deal 1 damage to the enemy
	if (area.name == "Player" and area.get_parent().is_dashing):
		var damage: int = 1  # Amount of damage this object deals
		var knockback_force: Vector2 = Vector2(500, -300)  # Knockback force when hitting the player
		var knockback_direction = (area.global_position - global_position).normalized()
		area.take_damage(damage, knockback_direction * knockback_force)


func take_damage(damage: int, _attacker_position: Vector2):
	if is_dead:
		return 

	health -= damage

	# Flash effect (white color for 0.1s)
	animatedsprite.modulate = Color(1, 1, 1, 0.5)  
	await get_tree().create_timer(0.1).timeout
	animatedsprite.modulate = Color(1, 1, 1, 1)  

	if health <= 0:
		die()


func die():
	if is_dead:
		return  # Prevent multiple calls


	#ToDO - Remove hurt hitbox
	is_dead = true  # Mark as dead
	times_dead += 1
	if times_dead > 3:
		#Insert win logic here
		Global.bosses[0] = true
		Global.has_laser_ability = true
		var scene_path = get_tree().current_scene.scene_file_path
		Global.place = scene_path.get_file().get_basename()
		Global.save_game(Global.place, 100)
		laserbossdead.emit()
		Global.load_game()
		queue_free()
		pass
	animatedsprite.animation = "teleport"
	animatedsprite.play()
	bounce_sound.play()

	# Wait before respawning
	await get_tree().create_timer(3).timeout  # Adjust time as needed

	# Respawn logic
	var cool = positions[randi() % 4 + 1]
	global_position = Vector2(cool)
	shoot_laser()
	health = 5
	is_dead = false
	animatedsprite.animation = "default"
	animatedsprite.play()


func shoot_laser() -> void:
	laser_sound.play()
	var laser = laser_scene.instantiate()
	# Calculate the offset based on the player's facing direction
	var offset = Vector2(200 if not animated_sprite.flip_h else -200, 0) #If offset any smaller we lose laser :hdsob:
	laser.global_position = global_position + offset
	laser.direction = Vector2(1 if not animated_sprite.flip_h else -1, 0)
	
	# Add the laser to the current scene
	get_tree().current_scene.add_child(laser)
