extends Area2D

@export var ability_name: String = "laser"  # Must match exactly: "laser", "glide", "dash", or "ground_pound"
@export var respawn_if_ability_unlocked: bool = false
@export var collection_sound: AudioStreamPlayer2D  # Optional: Assign in inspector

func _ready():
	# Wait until Global is fully loaded
	await get_tree().process_frame
	
	var global = get_node("/root/Global")
	
	# Debug initial states
	print("--- Collectible Init ---")
	print("Type: ", ability_name)
	print("Global.powers state: ", global.powers.get(ability_name, false))
	print("Individual var state: ", _get_individual_var_state(global))
	
	# Verify ability_name is valid
	if not ability_name in global.powers:
		push_error("Invalid ability_name: " + ability_name)
		queue_free()
		return
	
	# Connect signal
	body_entered.connect(_on_body_entered)
	
	# Hide if already collected
	if global.powers[ability_name]:
		if not respawn_if_ability_unlocked:
			print("Already collected - removing")
			queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		var global = get_node("/root/Global")
		
		# Debug before collection
		print("\n--- Collecting ", ability_name, " ---")
		print("BEFORE:")
		print("Global.powers: ", global.powers[ability_name])
		print("Individual var: ", _get_individual_var_state(global))
		
		# Update both tracking systems
		global.powers[ability_name] = true
		_update_individual_var(global, true)
		
		# Debug after update
		print("AFTER:")
		print("Global.powers: ", global.powers[ability_name])
		print("Individual var: ", _get_individual_var_state(global))
		
		# Save and handle collection
		global.save_game(global.player_location, global.player_health)
		_play_collection_effects()
		queue_free()

func _update_individual_var(global, value: bool):
	match ability_name:
		"laser":
			global.has_laser_ability = value
		"glide":
			global.has_glide_partner = value
		"dash":
			global.has_dash_ability = value
		"ground_pound":
			global.has_ground_pound_ability = value

func _get_individual_var_state(global):
	match ability_name:
		"laser":
			return global.has_laser_ability
		"glide":
			return global.has_glide_partner
		"dash":
			return global.has_dash_ability
		"ground_pound":
			return global.has_ground_pound_ability
		_:
			return null

func _play_collection_effects():
	print("Playing collection effects for: ", ability_name)
	
	# Visual effects
	$Sprite2D.visible = false
	if has_node("Particles2D"):
		$Particles2D.emitting = true
	
	# Sound effect
	if collection_sound and collection_sound.stream:
		collection_sound.play()
		await collection_sound.finished
	
	# Optional: Add animation player logic here if you have animations
