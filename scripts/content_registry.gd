class_name ContentRegistry
extends Node

enum RandomType {
	# Consistent for the player even across different lobbies
	CONSISTENT,
	# Consistent for a player within the current lobby (based on the player pid)
	PLAYER_RANDOM,
	# Full random every time the generator is called
	FULLY_RANDOM,
}

class AttributeGenerator:
	var generator_name: String
	# (PiacInfo, RandomNumberGenerator) -> bool
	var generator_func: Callable
	var random_type: RandomType
	var version: int

	func _init(p_generator_name: String, p_generator_func: Callable, p_random_type: RandomType, p_version: int) -> void:
		self.generator_name = p_generator_name
		self.generator_func = p_generator_func
		self.random_type = p_random_type
		self.version = p_version

var _attribute_generators: Dictionary[String, AttributeGenerator] = {}

func register_attribute_generator(generator: AttributeGenerator) -> bool:
	if _attribute_generators.has(generator.generator_name):
		push_warning("Tried to register trait generator ", generator.generator_name, " twice. Ignoring.")
		return false

	if generator.generator_func.get_argument_count() != 2:
		push_error("Failed to register trait generator ", generator.generator_name, " with an invalid number of arguments. Should take 2 args (PiacInfo, RandomNumberGenerator) and return a boolean for success.")
		return false

	_attribute_generators[generator.generator_name] = generator
	return true

func get_attribute_generators() -> Dictionary[String, AttributeGenerator]:
	return _attribute_generators.duplicate()
