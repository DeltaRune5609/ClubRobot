extends Area2D

var myglobal = global_position
var player: Node2D = null

func _ready() -> void:
	if Global.keys[0] == true:
		queue_free()
		
func _process(delta) -> void:
	if Global.keys[0] == true:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		myglobal = Global.player_position
		Global.keys[0] = true
		queue_free()
		Global.save_game('key', 100)
		pass
