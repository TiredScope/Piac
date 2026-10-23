class_name ContentRegistry
extends RefCounted

var _trait_generators: Dictionary[String, Callable] = {}

func register_trait_generator(name: String, callback: Callable) -> bool:
	if _trait_generators.has(name):
		return false

	if callback.get_argument_count() != 2:
		push_error("Failed to register trait_generator ", name, " with an invalid number of arguments. Should take 2 args (PiacData, RandomNumberGenerator) and return a boolean for success.")
		return false

	_trait_generators[name] = callback
	return true

func get_trait_generators() -> Dictionary[String, Callable]:
	return _trait_generators.duplicate()
