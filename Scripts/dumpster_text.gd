extends Area2D

@export var fade_text: Label

var current_tween: Tween

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		if current_tween:
			current_tween.kill()
		
		current_tween = create_tween()
		current_tween.tween_property(fade_text, "modulate:a", 1.0, 1.0)		
		current_tween.tween_property(fade_text, "modulate:a", 0.0, 1.0)
		current_tween.tween_interval(2.0)
		current_tween.tween_property(fade_text, "modulate:a", 1.0, 0.0)
