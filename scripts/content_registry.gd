class_name ContentRegistry
extends Node

class TraitGeneratorInstance:
	var name: String
	var generator_func: Callable
	var version: int

var _trait_generators: Dictionary[String, Callable] = {}

func register_trait_generator(generator_name: String, callback: Callable, version: int = 0) -> bool:
	if _trait_generators.has(generator_name):
		return false

	if callback.get_argument_count() != 2:
		push_error("Failed to register trait_generator ", name, " with an invalid number of arguments. Should take 2 args (PiacData, RandomNumberGenerator) and return a boolean for success.")
		return false

	_trait_generators[generator_name] = callback
	return true

func get_trait_generators() -> Dictionary[String, Callable]:
	return _trait_generators.duplicate()
