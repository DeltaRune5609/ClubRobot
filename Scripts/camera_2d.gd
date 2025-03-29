extends Camera2D

@export var target: NodePath
@export var offset_distance: float = 10000.0 
@export var smooth_speed: float = 5.0 

var player: CharacterBody2D
var target_offset: Vector2 = Vector2.ZERO

func _ready():
	if target:
		player = get_node(target)

func _process(delta: float):
	if player:
		var direction: float = Input.get_axis("ui_left", "ui_right")
		
		# Calculate the target offset
		if direction != 0:
			target_offset.x = direction * offset_distance
		else:
			target_offset.x = 0 

		position.x = lerp(position.x, player.position.x + target_offset.x, smooth_speed * delta)
		position.y = lerp(position.y, player.position.y, smooth_speed * delta)
