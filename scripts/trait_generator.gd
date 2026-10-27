class_name TraitGenerator # TODO: name

static func generate_hash(uid: PackedByteArray) -> PackedByteArray:
	# TODO: move out of TraitGenerator?
	var ctx: HashingContext = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(uid)
	return ctx.finish()

static func _generate_default_traits(player: PiacInfo, rng: RandomNumberGenerator) -> bool:
	var traits: PiacTraits = PiacTraits.generate(rng)
	PiacPlayerManager.save_traits(player, traits)
	return true

static func generate_traits(piac: PiacInfo) -> void:
	#var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	#rng.seed = get_seed_from_bytes(piac.uid_hash)

	# Default traits (TODO: register like all others?)

	var trait_generators: Dictionary[String, ContentRegistry.TraitGeneratorInstance] = PiacRegistry.get_trait_generators()
	var executed_generators: Dictionary[String, int] = PiacPlayerManager.get_executed_generators(piac)

	for generator_name: String in trait_generators:
		var generator: ContentRegistry.TraitGeneratorInstance = trait_generators[generator_name]
		if executed_generators.has(generator_name) and executed_generators[generator_name] >= generator.version:
			# Generator has already been executed
			continue

		var rng: RandomNumberGenerator = RandomNumberGenerator.new()

		match generator.random_type:
			ContentRegistry.RandomType.CONSISTENT:
				rng.seed = get_seed_from_bytes(piac.uid_hash) ^ generator_name.hash() # TODO: better way to seed rng?
			ContentRegistry.RandomType.PLAYER_RANDOM:
				rng.seed = get_seed_from_bytes(piac.uid_hash) ^ get_seed_from_bytes(piac.pid) ^ generator_name.hash() # TODO: better way to seed rng?
			ContentRegistry.RandomType.FULLY_RANDOM:
				pass # RandomNumberGenerator uses a random seed by default

		var ok: bool = generator.generator_func.call(piac, rng)
		ok = ok and PiacPlayerManager.save_executed_generator(piac, generator_name, generator.version)
		if not ok:
			push_error("Failed to generate traits for ", generator_name)

static func get_seed_from_bytes(uid_hash: PackedByteArray) -> int:
	var generated_seed: int = 0
	for i: int in uid_hash.to_int64_array():
		generated_seed ^= i
	return generated_seed
