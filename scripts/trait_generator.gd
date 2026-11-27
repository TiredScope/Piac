class_name TraitGenerator # TODO: name

static var GENERATOR: ContentRegistry.AttributeGenerator = ContentRegistry.AttributeGenerator.new(
	"default",
	generate_traits,
	ContentRegistry.RandomType.CONSISTENT,
	0
)

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

static func generate_traits(piac: PiacInfo) -> bool:
	#var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	#rng.seed = get_seed_from_bytes(piac.uid_hash)

	# Default traits (TODO: register like all others?)

	var attribute_generators: Dictionary[String, ContentRegistry.AttributeGenerator] = PiacRegistry.get_attribute_generators()
	var executed_generators: Dictionary[String, int] = PiacPlayerManager.get_executed_generators(piac)

	var ok: bool = true

	for generator_name: String in attribute_generators:
		var generator: ContentRegistry.AttributeGenerator = attribute_generators[generator_name]
		if executed_generators.has(generator_name) and executed_generators[generator_name] >= generator.version:
			# Generator has already been executed
			continue

		var rng: RandomNumberGenerator = RandomNumberGenerator.new()

		match generator.random_type:
			ContentRegistry.RandomType.CONSISTENT:
				rng.seed = get_seed_from_bytes(piac.uid_hash) ^ generator_name.hash() # TODO: better way to seed rng?
			ContentRegistry.RandomType.PLAYER_RANDOM:
				rng.seed = get_seed_from_bytes(piac.uid_hash) ^ piac.pid ^ generator_name.hash() # TODO: better way to seed rng?
			ContentRegistry.RandomType.FULLY_RANDOM:
				pass # RandomNumberGenerator uses a random seed by default

		var this_ok: bool = generator.generator_func.call(piac, rng)
		this_ok = this_ok and PiacPlayerManager.save_executed_generator(piac, generator_name, generator.version)
		if not this_ok:
			ok = false
			push_error("Failed to generate attributes for ", generator_name)

	return ok

static func get_seed_from_bytes(uid_hash: PackedByteArray) -> int:
	var generated_seed: int = 0
	for i: int in uid_hash.to_int64_array():
		generated_seed ^= i
	return generated_seed
