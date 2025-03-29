extends Area2D

# The path to the scene to load when the player interacts with the door
@export var next_scene_path: String = "res://Levels/offices.tscn"

# Reference to the player node
var player: Node2D = null

# Reference to the transition scene
@onready var transition_scene = preload("res://scenes(enemiesanditems)/transition.tscn")

func _ready() -> void:
	# Connect the area's signals to detect when the player enters and exits
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _process(delta: float) -> void:
	# Check if the player is touching the door and pressing the "up" key
	if player and Input.is_action_just_pressed("ui_up") and Global.bosses[3] == true:
		# Start the transition and load the next scene
		start_transition()

func _on_body_entered(body: Node2D) -> void:
	# Check if the body that entered is the player
	if body.name == "player":
		player = body

func _on_body_exited(body: Node2D) -> void:
	# Check if the body that exited is the player
	if body.name == "player":
		player = null

func start_transition() -> void:
	# Instantiate the transition scene
	var transition = transition_scene.instantiate()
	get_tree().current_scene.add_child(transition)

	# Connect to the transition's signal to know when it finishes
	transition.on_transition_finished.connect(_on_transition_finished)

	# Start the transition animation
	transition.transition()

func _on_transition_finished() -> void:
	var scene_path = get_tree().current_scene.scene_file_path
	var place = scene_path.get_file().get_basename()
	Global.save_game(place, 100)
	get_tree().change_scene_to_file(next_scene_path)
