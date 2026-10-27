class_name Companion
extends Node2D

@onready var sprite: AnimatedSprite2D = $Sprite

var t: float = 0
var target_pos: Vector2 = Vector2.ZERO
var sit_timeout: float = 1

func _ready() -> void:
	sprite.play("sit")

func _process(delta: float) -> void:
	t += delta

	if sit_timeout > 0:
		sit_timeout -= delta

		if sit_timeout <= 0:
			sit_timeout = 0
			var screen_size: Vector2 = get_viewport_rect().size
			target_pos = Vector2(randf() * screen_size.x, randf() * screen_size.y)
			sprite.play("move")

		return

	if (target_pos - position).length() < 10:
		sit_timeout = randf_range(3, 10)
		sprite.play("sit")

	var bob: Vector2 = sin(t * 2 * PI * 10 / 4) * Vector2.UP * 10
	sprite.position = bob

	var move: Vector2 = (target_pos - position).normalized()
	sprite.flip_h = move.x < 0
	position += move
