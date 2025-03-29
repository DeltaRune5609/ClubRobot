extends TextureProgressBar

@onready var player: CharacterBody2D = $".."

func _ready() -> void:
	player.changeHealth.connect(update)
	update()

func update():
	value = player.health * 10 / player.max_health
