extends Node

func get_player(uid_hash: PackedByteArray) -> PiacInfo:
	var ok: bool = DBProvider.sql.query_with_named_bindings("SELECT * FROM piac WHERE uid_hash = :uid_hash", {"uid_hash": uid_hash})
	if not ok or DBProvider.sql.query_result.is_empty():
		push_error("Query failed: ", DBProvider.sql.error_message)
		return null

	var result: Dictionary = DBProvider.sql.query_result[0]
	print("THE RESULT IS ", result)
	var player: PiacInfo = PiacInfo.new()
	player.uid_hash = uid_hash
	player.uid = result["uid"] as PackedByteArray
	player.name = result["name"]
	return player

func create_new_player(uid: PackedByteArray, player_name: String) -> PiacInfo:
	var player: PiacInfo = PiacInfo.new()
	player.uid = uid
	player.uid_hash = TraitGenerator.generate_hash(uid)
	player.name = player_name

	if not save_player(player):
		return null

	return player

func save_player(player: PiacInfo) -> bool:
	return DBProvider.sql.insert_row("piac", {
		"uid_hash": player.uid_hash,
		"uid": player.uid,
		"name": player.name,
	})

func save_traits(player: PiacInfo, traits: PiacTraits) -> bool:
	return DBProvider.sql.insert_row("piac_traits", {
		"uid_hash": player.uid_hash,
		"activity_level":  traits.activity_level,
		"expressiveness": traits.expressiveness,
	})
