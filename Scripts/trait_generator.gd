class_name TraitGenerator

class Traits:
	var _uid_hash: PackedByteArray

	func _init(uid_hash: PackedByteArray):
		self._uid_hash = uid_hash

	func _to_string() -> String:
		return "[hash: %s]" % [_uid_hash.hex_encode()]

static func generate_traits(uid: PackedByteArray) -> Traits:
	var ctx = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(uid)
	var uid_hash: PackedByteArray = ctx.finish()
	return Traits.new(uid_hash)
