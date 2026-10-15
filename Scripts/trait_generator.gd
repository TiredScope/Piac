class_name TraitGenerator

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
	#rng.seed = get_seed_from_hash(piac.uid_hash)

	## Default traits (TODO: register like all others?)

	var trait_generators: Dictionary[String, Callable] = PiacRegistry.get_trait_generators()
	for generator_name: String in trait_generators:
		# TODO: check if already generated, save generated names

		var generator: Callable = trait_generators[generator_name]
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = get_seed_from_hash(piac.uid_hash) ^ generator_name.hash() # TODO: better way to seed rng?
		var ok: bool = generator.call(piac, rng)
		if not ok:
			push_error("Failed to generate traits for ", generator_name)

static func get_seed_from_hash(uid_hash: PackedByteArray) -> int:
	var generated_seed: int = 0
	for i: int in uid_hash.to_int64_array():
		generated_seed ^= i
	return generated_seed
