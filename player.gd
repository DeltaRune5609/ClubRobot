extends CharacterBody2D

signal orbspawn
signal changeHealth

# Movement constants
const MAX_SPEED = 900.0
const ACCELERATION = 3800.0
const DECELERATION = 4200.0
const AIR_ACCELERATION = 1900.0
const AIR_DECELERATION = 2100.0
const GLIDE_ACCELERATION = 3000.0
const JUMP_VELOCITY = -1500.0
const FIXED_JUMP_VELOCITY = -1200.0
const WALL_JUMP_VELOCITY = Vector2(5000.0, -1200.0)
const MAX_WALL_JUMP_SPEED = 1200.0
const GRAVITY = 2500.0
const GLIDE_GRAVITY = 800.0
const COYOTE_TIME = 0.2
const MIN_JUMP_VELOCITY = -400.0
const KNOCKBACK_FORCE = Vector2(1000.0, -500.0)
const INVINCIBILITY_TIME = 1.0
const HIT_FREEZE_TIME = 1.0
const SHOOT_FREEZE_TIME = 0.2
const DASH_SPEED = 2000.0
const DASH_DURATION = 0.1
const DASH_COOLDOWN = 0.0
const DOUBLE_TAP_THRESHOLD = 0.3
const DASH_INVINCIBILITY_TIME = 0.5
const DASH_DAMAGE = 1 
const GROUND_POUND_SPEED = 2000.0
const GROUND_POUND_BOUNCE_VELOCITY = -800.0
const GROUND_POUND_INVINCIBILITY_TIME = 1.0

# Player state variables
var coyote_timer := 0.0
var was_on_floor := false
var is_jumping := false
var is_touching_wall := false
var wall_direction := 0
var is_wall_jump_chaining := false
var is_gliding := false
var has_glide_partner := true
var has_laser_ability := true
var has_dash_ability := true
var has_ground_pound_ability := true
var wall_jump_chain_count := 0
var health := 5
var is_invincible := false
var is_hit := false
var hit_timer := 0.0
var is_shooting := false
var shoot_timer := 0.0
var is_dashing := false 
var dash_timer := 0.0 
var dash_cooldown_timer := 0.0
var last_tap_time := 0.0
var last_tap_direction := 0 
var is_ground_pounding := false  
var max_health := 10
var damage_taken_buffer: float = 0.0


# Node references
@onready var left_raycast: RayCast2D = $LeftRayCast
@onready var right_raycast: RayCast2D = $RightRayCast
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var laser_sound: AudioStreamPlayer2D = $LaserSound  # Reference to the LaserSound node
@onready var dash_sound: AudioStreamPlayer2D = $DashSound  # Reference to the DashSound node
@onready var drill_sound: AudioStreamPlayer2D = $DrillSound  # Reference to the DrillSound node
@onready var laser_scene = preload("res://Levels/pew.tscn")  # Updated to use the pew scene
@onready var orb_scene = preload("res://orb.tscn")
@onready var hpbar: TextureProgressBar = $hpbar

func _ready() -> void:
	orbspawn.connect(spawnorb)
	

func spawnorb(damage_amount: float):
	var orb_count = ceil(damage_amount / 10.0)
	
	for i in orb_count:
		var orb = orb_scene.instantiate()
		orb.target = self
		orb.heal_value = damage_taken_buffer / orb_count
		var offset = Vector2(80 if not animated_sprite.flip_h else -80, 0)
		orb.direction = Vector2(1 if not animated_sprite.flip_h else -1, 0)
		call_deferred("_add_orb", orb, global_position + offset)

func _add_orb(orb: Node, position: Vector2):
	get_tree().current_scene.add_child(orb)
	orb.global_position = position

func _physics_process(delta: float) -> void:
	if is_hit:
		hit_timer -= delta
		if hit_timer > 0:
			velocity = Vector2.ZERO
			move_and_slide()
			return
		else:
			is_hit = false
			animated_sprite.play("stand")
			if is_on_floor():
				is_invincible = false

	if is_shooting:
		shoot_timer -= delta
		if shoot_timer > 0:
			velocity = Vector2.ZERO
			move_and_slide()
			return
		else:
			is_shooting = false
			animated_sprite.play("stand")

	if is_dashing:
		dash_timer -= delta
		if dash_timer > 0:
			velocity.x = DASH_SPEED * last_tap_direction
			velocity.y = 0  # Prevent gravity during dash
			is_invincible = true
			move_and_slide()

			for i in get_slide_collision_count():
				var collision = get_slide_collision(i)
				var collider = collision.get_collider()
				if collider.has_method("take_damage"):
					collider.take_damage(DASH_DAMAGE, global_position)
		else:
			is_dashing = false
			dash_cooldown_timer = DASH_COOLDOWN 
			is_invincible = true
			await get_tree().create_timer(DASH_INVINCIBILITY_TIME).timeout
			is_invincible = false

	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	if not is_on_floor():
		if is_gliding:
			velocity.y += GLIDE_GRAVITY * delta
		else:
			velocity.y += GRAVITY * delta
	else:
		velocity.y = 0
		is_wall_jump_chaining = false
		is_gliding = false
		wall_jump_chain_count = 0

	# Handle coyote time
	if is_on_floor():
		was_on_floor = true
		coyote_timer = COYOTE_TIME
	else:
		if was_on_floor:
			coyote_timer -= delta
		else:
			coyote_timer = 0.0

	# Detect if the player is touching a wall
	detect_wall()

	# Handle jump with coyote time
	if Input.is_action_just_pressed("ui_up") and (is_on_floor() or coyote_timer > 0):
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0
		is_jumping = true
		is_wall_jump_chaining = false
		play_jump_sound(1.0)

	# Variable jump height
	if is_jumping:
		if not Input.is_action_pressed("ui_up") or velocity.y >= MIN_JUMP_VELOCITY:
			velocity.y = max(velocity.y, MIN_JUMP_VELOCITY)
			is_jumping = false

	# Handle second jump button (fixed height - space bar)
	if Input.is_action_just_pressed("ui_select"):
		if is_on_floor() or coyote_timer > 0:
			velocity.y = FIXED_JUMP_VELOCITY
			coyote_timer = 0.0
			is_jumping = false
			is_wall_jump_chaining = true
			play_jump_sound(1.5)
		elif is_touching_wall:
			velocity.x = WALL_JUMP_VELOCITY.x * -wall_direction
			velocity.y = WALL_JUMP_VELOCITY.y
			is_jumping = false
			is_wall_jump_chaining = true
			wall_jump_chain_count += 1
			play_jump_sound(1.0 + min(wall_jump_chain_count * 0.2, 4.0))

	# Automatically wall jump if in a wall jump chain and touching a wall
	if is_wall_jump_chaining and is_touching_wall and not is_on_floor():
		velocity.x = WALL_JUMP_VELOCITY.x * -wall_direction
		velocity.y = WALL_JUMP_VELOCITY.y
		wall_jump_chain_count += 1
		play_jump_sound(1.0 + min(wall_jump_chain_count * 0.2, 4.0))

	if Input.is_action_pressed("ui_up") and not is_on_floor() and not is_jumping and not is_wall_jump_chaining and has_glide_partner:
		is_gliding = true
	else:
		is_gliding = false

	# Clamp horizontal velocity after wall jump
	velocity.x = clamp(velocity.x, -MAX_WALL_JUMP_SPEED, MAX_WALL_JUMP_SPEED)

	# Handle horizontal movement with momentum
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		if is_on_floor():
			velocity.x += direction * ACCELERATION * delta
		else:
			if is_gliding:
				velocity.x += direction * GLIDE_ACCELERATION * delta
			else:
				velocity.x += direction * AIR_ACCELERATION * delta
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	else:
		if is_on_floor():
			if velocity.x > 0:
				velocity.x = max(velocity.x - DECELERATION * delta, 0)
			elif velocity.x < 0:
				velocity.x = min(velocity.x + DECELERATION * delta, 0)
		else:
			if velocity.x > 0:
				velocity.x = max(velocity.x - AIR_DECELERATION * delta, 0)
			elif velocity.x < 0:
				velocity.x = min(velocity.x + AIR_DECELERATION * delta, 0)

	if Input.is_action_just_pressed("ui_down") and not is_shooting and is_on_floor() and has_laser_ability:
		shoot_laser()

	if is_on_floor() and dash_cooldown_timer <= 0 and has_dash_ability:
		if Input.is_action_just_pressed("ui_left"):
			handle_dash_input(-1)  # Dash to the left
		elif Input.is_action_just_pressed("ui_right"):
			handle_dash_input(1)  # Dash to the right

	if Input.is_action_just_pressed("ui_down") and not is_on_floor() and not is_ground_pounding and has_ground_pound_ability:
		start_ground_pound()

	if is_ground_pounding:
		velocity.y = GROUND_POUND_SPEED
		is_invincible = true
		move_and_slide()

		if is_on_floor():
			end_ground_pound()

	move_and_slide()

func handle_dash_input(direction: int) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0  # Convert to seconds
	if last_tap_direction == direction and current_time - last_tap_time <= DOUBLE_TAP_THRESHOLD:
		# Double tap detected, start dash
		start_dash(direction)
	last_tap_direction = direction
	last_tap_time = current_time

func start_dash(direction: int) -> void:
	if is_dashing or dash_cooldown_timer > 0:
		return  # Prevent dashing while already dashing or during cooldown

	is_dashing = true
	dash_timer = DASH_DURATION
	last_tap_direction = direction
	is_invincible = true 
	dash_sound.play()

func start_ground_pound() -> void:
	is_ground_pounding = true
	is_invincible = true
	drill_sound.play()

func end_ground_pound() -> void:
	is_ground_pounding = false
	velocity.y = GROUND_POUND_BOUNCE_VELOCITY

	# Keep the player invincible for 1 second after the ground pound ends
	is_invincible = true
	await get_tree().create_timer(GROUND_POUND_INVINCIBILITY_TIME).timeout
	is_invincible = false

func detect_wall():
	is_touching_wall = false
	wall_direction = 0

	if left_raycast.is_colliding():
		is_touching_wall = true
		wall_direction = -1
	elif right_raycast.is_colliding():
		is_touching_wall = true
		wall_direction = 1

func play_jump_sound(pitch: float) -> void:
	jump_sound.pitch_scale = pitch
	jump_sound.play()

func play_hurt_sound() -> void:
	hurt_sound.play()

func take_damage(damage: int, attacker_position: Vector2):
	if is_invincible or is_hit:
		return

	health -= damage
	changeHealth.emit()
	if health <= 0:
		die()
	else:
		is_hit = true
		hit_timer = HIT_FREEZE_TIME
		var hazard_direction = sign(attacker_position.x - global_position.x)
		animated_sprite.flip_h = hazard_direction == 1
		animated_sprite.play("hit")
		play_hurt_sound()
		orbspawn.emit(damage)
		is_invincible = true
		var invincibility_timer = get_tree().create_timer(INVINCIBILITY_TIME)
		await invincibility_timer.timeout
		is_invincible = false

func die():
	#Add a game over explosion of Coby and then activate the game over screen 
	pass

func heal():
	health += 1
	changeHealth.emit()


func shoot_laser() -> void:
	is_shooting = true
	shoot_timer = SHOOT_FREEZE_TIME
	animated_sprite.play("shoot")

	laser_sound.play()

	# Create a laser instance
	var laser = laser_scene.instantiate()
	# Calculate the offset based on the player's facing direction
	var offset = Vector2(60 if not animated_sprite.flip_h else -60, 0) #If offset any smaller we lose laser :hdsob:
	laser.global_position = global_position + offset
	laser.direction = Vector2(1 if not animated_sprite.flip_h else -1, 0)
	
	# Add the laser to the current scene
	get_tree().current_scene.add_child(laser)
