class_name TraitGenerator

static func generate_hash(uid: PackedByteArray) -> PackedByteArray:
	# TODO: move out of TraitGenerator?
	var ctx: HashingContext = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(uid)
	return ctx.finish()

static func generate_traits(uid_hash: PackedByteArray) -> PiacTraits:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = get_seed_from_hash(uid_hash)

	var traits: PiacTraits = PiacTraits.new()
	traits.activity_level = rng.randf()
	traits.expressiveness = rng.randf()
	return traits

static func get_seed_from_hash(uid_hash: PackedByteArray) -> int:
	var generated_seed: int = 0
	for i: int in uid_hash.to_int64_array():
		generated_seed ^= i
	return generated_seed
