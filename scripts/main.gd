extends Node

func _ready() -> void:
	var test_uid: PackedByteArray = [1, 2, 3, 4, 5, 6, 7]
	var uid_hash: PackedByteArray = TraitGenerator.generate_hash(test_uid)
	var p: PiacInfo = PiacPlayerManager.get_player(uid_hash)
	print(p)

	PiacRegistry.register_trait_generator("default", TraitGenerator._generate_default_traits, ContentRegistry.RandomType.CONSISTENT)

	if p == null:
		p = PiacPlayerManager.create_new_player(test_uid, "Hello World!")
		print("Made new player: ", p)

	TraitGenerator.generate_traits(p)
