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

class TraitGeneratorInstance:
	var generator_name: String
	var generator_func: Callable
	var random_type: RandomType
	var version: int

var _trait_generators: Dictionary[String, TraitGeneratorInstance] = {}

func register_trait_generator(generator_name: String, callback: Callable, random_type: RandomType, version: int = 0) -> bool:
	if _trait_generators.has(generator_name):
		return false

	if callback.get_argument_count() != 2:
		push_error("Failed to register trait generator ", name, " with an invalid number of arguments. Should take 2 args (PiacData, RandomNumberGenerator) and return a boolean for success.")
		return false

	var generator: TraitGeneratorInstance = TraitGeneratorInstance.new()
	generator.generator_name = generator_name
	generator.generator_func = callback
	generator.random_type = random_type
	generator.version = version
	_trait_generators[generator_name] = generator
	return true

func get_trait_generators() -> Dictionary[String, TraitGeneratorInstance]:
	return _trait_generators.duplicate()
