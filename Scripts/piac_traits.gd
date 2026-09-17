class_name PiacTraits
extends Resource

var activity_level: float
var expressiveness: float

func _to_string() -> String:
	return "[activity_level: %.2f, expressiveness: %.2f]" % [activity_level, expressiveness]
