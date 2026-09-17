extends Node2D

@onready var player_manager: PlayerManager = $PlayerManager

func _ready() -> void:
	var test_uid: PackedByteArray = [1, 2, 3, 4, 5, 6, 7]
	var uid_hash: PackedByteArray = TraitGenerator.generate_hash(test_uid)
	var p: PiacInfo = player_manager.get_player(uid_hash)
	print(p)

	if p == null:
		p = player_manager.create_new_player(test_uid, "Hello World!")
		print("Made new player: ", p)
