class_name PiacTraits
extends Resource

static var GENERATOR: ContentRegistry.AttributeGenerator = ContentRegistry.AttributeGenerator.new(
	"default",
	_generate_traits,
	ContentRegistry.RandomType.CONSISTENT,
	0
)

var activity_level: float
var expressiveness: float

func _to_string() -> String:
	return "[activity_level: %.2f, expressiveness: %.2f]" % [activity_level, expressiveness]

static func generate(rng: RandomNumberGenerator) -> PiacTraits:
	var traits: PiacTraits = PiacTraits.new()
	traits.activity_level = rng.randf()
	traits.expressiveness = rng.randf()
	return traits

static func _generate_traits(player: PiacInfo, rng: RandomNumberGenerator) -> bool:
	var traits: PiacTraits = PiacTraits.generate(rng)
	PiacPlayerManager.save_traits(player, traits)
	return true
