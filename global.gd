extends Node  # General-purpose node

# Global variables (modify as needed)
var player_health: int = 5
var player_score: int = 0
var player_position: Vector2 = Vector2()  # Initialize to a default value

# Dictionary holding default positions per location
var saved_pos = {
	"dumpster": Vector2(0, -10500),
	"cafeteria": Vector2(-4000, 0),
	"laserarea": Vector2(-2250, -350),
	"glidearea": Vector2(-2250, -350),
	"hydrosim": Vector2(-3750, 0),
	"BossLevel": Vector2(-3570, -53),
	"bosslaser": Vector2(-4000, -53),
	"bosslocust": Vector2(-4000, -53),
	"bossdrill": Vector2(-4000, -53),
	"bossdash": Vector2(-4000, -53),
	"offices": Vector2(0, 0)
	# Add others here by name
}

var has_glide_partner := false
var has_laser_ability := false
var has_dash_ability := false
var has_ground_pound_ability := false

var powers = {
	"laser": true,
	"glide": true,
	"dash": false,
	"ground_pound": true
}

var player_location = ""
var place = ""
var played = false
var keys = [false, false]
var bosses = [false, false, false, false]
func _ready():
	#WARNING Do not uncomment the next line of code unless you want to obliterate your save file. Debugging purposes only.
	#_delete_save('juiceshanghai')  #Give correct password, delete file
	load_game()
	if not played:
		played = true
		print("first load, saving initial state")
		# For example, saving at "dumpster" with health value 69 triggers a special reset
		save_game("bosslocust", 70)

# Save game function; "place" is the location key, "health" is the player's health.
func save_game(place: String, health: int):
	# Special handling: if health equals 69, reset player_position and override health.
	if health == 69:
		player_position = Vector2(0, -10500)
		health = 5
	elif health == 70:
		player_position = Vector2(-4000, -53)
		health = 5
	else:
		# Otherwise, update the saved position for this place
		saved_pos[place] = Vector2(player_position.x, player_position.y)
	
	# Update player_health only if not the special case.
	if health != 69:
		player_health = health
	if health == 100:
		health = 5
		player_health = health
	
	if place == 'key':
		place = player_location
		pass
	saved_pos[place] = player_position
	# Create the data dictionary; note that "entire" stores the whole saved_pos dictionary.
	var data = {
		"player_health": health,
		"player_score": player_score,
		"player_location": place,
		"has_laser_ability": powers["laser"],
		"has_glide_partner": powers["glide"],
		"has_dash_ability": powers["dash"],
		"has_ground_pound_ability": powers["ground_pound"],
		"played": played,
		"1key": keys[0],
		"2key": keys[1],
		"entire": saved_pos,
		"dead0": bosses[0],
		"dead1": bosses[1],
		"dead2": bosses[2],
		"dead3": bosses[3],
	}
	
	# Convert the data to JSON and write it to file.
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	print("Game saved:", JSON.stringify(data))

# Load game function.
func load_game():
	if FileAccess.file_exists("user://savegame.json"):
		var file = FileAccess.open("user://savegame.json", FileAccess.READ)
		var content = file.get_as_text()
		print("Raw JSON content:", content)  # Debug print
		file.close()

		var data = JSON.parse_string(content)
		if data:
			# Load basic values.
			player_health = data.get("player_health", 5)
			player_score = data.get("player_score", 0)
			
			var location = data.get("player_location", "dumpster")
			# Convert the saved player_position dictionary to a Vector2.
			if saved_pos.has(place):
				var pos_entry = saved_pos[place]
				if typeof(pos_entry) == TYPE_STRING:
					pos_entry = pos_entry.strip_edges().trim_prefix("(").trim_suffix(")").split(", ")
					if pos_entry.size() == 2:
						player_position = Vector2(float(pos_entry[0]), float(pos_entry[1]))
				elif typeof(pos_entry) == TYPE_DICTIONARY and "x" in pos_entry and "y" in pos_entry:
					player_position = Vector2(pos_entry.x, pos_entry.y)

			
			# Load other abilities and flags.
			has_laser_ability = data.get("has_laser_ability", false)
			has_glide_partner = data.get("has_glide_partner", false)
			has_dash_ability = data.get("has_dash_ability", false)
			has_ground_pound_ability = data.get("has_ground_pound_ability", false)
			keys[0] = data.get("1key", false)
			keys[1] = data.get("2key", false)
			played = data.get("played", false)
			# Reload the entire saved positions dictionary.
			saved_pos = data.get("entire", saved_pos)
			bosses[0] = data.get("dead0", false)
			bosses[1] = data.get("dead1", false)
			bosses[2] = data.get("dead2", false)
			bosses[3] = data.get("dead3", false)
			player_location = location
		
			
			print("Game loaded successfully!")
		else:
			print("Error parsing JSON save file.")

func load_game2():
	load_game()
	get_tree().change_scene_to_file("res://Levels/%s.tscn" % player_location)

func givememypos(place: String):
	if saved_pos.has(place):
		var pos_entry = saved_pos[place]
		
		# Check if it's a string (which is incorrect format)
		if typeof(pos_entry) == TYPE_STRING:
			# Remove parentheses and split by ", "
			pos_entry = pos_entry.strip_edges().trim_prefix("(").trim_suffix(")").split(", ")
			
			# Convert to numbers and return Vector2
			if pos_entry.size() == 2:
				return Vector2(float(pos_entry[0]), float(pos_entry[1]))
		
		# If it's already stored as a dictionary with "x" and "y"
		elif typeof(pos_entry) == TYPE_DICTIONARY and "x" in pos_entry and "y" in pos_entry:
			return Vector2(pos_entry.x, pos_entry.y)
			
		else:
			return Vector2(0, -10500)
	
	else:
		return Vector2(0, -10500)

func _delete_save(failsafe):
	var file_path = "user://savegame.json"
	if true == true:
		if FileAccess.file_exists(file_path) and failsafe == 'juiceshanghai':
			DirAccess.remove_absolute(file_path)
			print("deleted")
