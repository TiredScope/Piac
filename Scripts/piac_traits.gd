class_name PiacTraits
extends Resource

var activity_level: float
var expressiveness: float

func _to_string() -> String:
	return "[activity_level: %.2f, expressiveness: %.2f]" % [activity_level, expressiveness]

static func generate(rng: RandomNumberGenerator) -> PiacTraits:
	var traits: PiacTraits = PiacTraits.new()
	traits.activity_level = rng.randf()
	traits.expressiveness = rng.randf()
	return traits
