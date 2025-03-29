extends Area2D

@export var health := 1  # Hits required to break
@onready var collision = $CollisionShape2D
@onready var sprite = $Sprite2D

func _ready():
  body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
  if body.is_in_group("player") or body.is_in_group("projectile"):
   take_damage(1)

func take_damage(amount: int):
  health -= amount
  if health <= 0:
   break_block()

func break_block():
  collision.set_deferred("disabled", true)
  sprite.hide()
  
  $AnimationPlayer.play("break")
  
  await get_tree().create_timer(0.5).timeout
  queue_free()
