extends Resource
class_name AnimationComponent

enum Type {
	SOLID,
	FADE_IN,
	FADE_OUT,
}

var neopixel: NeoPixelModule
var type: Type = Type.SOLID
var colors: Array[Color]
var duration: float = 1.0

var started: bool = false
var current_position: float = 0

func play(delta: float) -> void:
	current_position += delta

	match type:
		Type.SOLID:
			if not started:
				neopixel.set_colors(colors, 0, 0)

	started = true
	pass

func stop() -> void:
	started = false
	current_position = 0

func done() -> bool:
	return started and current_position >= duration
