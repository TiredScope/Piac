class_name PlayerManager
extends Node

func get_player(uid_hash: PackedByteArray) -> PiacInfo:
	var ok: bool = DBProvider.sql.query_with_named_bindings("SELECT * FROM piac WHERE uid_hash = :uid_hash", {"uid_hash": uid_hash})
	if not ok or DBProvider.sql.query_result.is_empty():
		print(DBProvider.sql.error_message)
		return null

	var result: Dictionary = DBProvider.sql.query_result[0]
	print(result)
	var player: PiacInfo = PiacInfo.new()
	player.uid_hash = uid_hash
	player.uid = PackedByteArray(result[0]["uid"])
	player.name = result[0]["name"]
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
