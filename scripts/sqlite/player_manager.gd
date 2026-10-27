class_name PlayerManager
extends Node

func get_piac(uid_hash: PackedByteArray) -> PiacInfo:
	var ok: bool = DBProvider.sql.query_with_named_bindings("SELECT * FROM piac WHERE uid_hash = :uid_hash", {"uid_hash": uid_hash})
	if not ok:
		push_error("Query failed: ", DBProvider.sql.error_message)
		return null

	if DBProvider.sql.query_result.is_empty():
		return null

	var result: Dictionary = DBProvider.sql.query_result[0]
	print("THE RESULT IS ", result)
	var piac: PiacInfo = PiacInfo.new()
	piac.uid_hash = uid_hash
	piac.uid = result["uid"] as PackedByteArray
	piac.name = result["name"]
	return piac

func create_new_piac(uid: PackedByteArray, player_name: String) -> PiacInfo:
	var piac: PiacInfo = PiacInfo.new()
	piac.uid = uid
	piac.uid_hash = TraitGenerator.generate_hash(uid)
	piac.name = player_name

	if not save_piac(piac):
		return null

	return piac

func save_piac(piac: PiacInfo) -> bool:
	return DBProvider.sql.insert_row("piac", {
		"uid_hash": piac.uid_hash,
		"uid": piac.uid,
		"name": piac.name,
	})

func save_traits(piac: PiacInfo, traits: PiacTraits) -> bool:
	return DBProvider.sql.insert_row("piac_traits", {
		"uid_hash": piac.uid_hash,
		"activity_level":  traits.activity_level,
		"expressiveness": traits.expressiveness,
	})

func get_executed_generators(piac: PiacInfo) -> Dictionary[String, int]:
	var ok: bool = DBProvider.sql.query_with_named_bindings("SELECT * FROM piac_generators WHERE uid_hash = :uid_hash", {"uid_hash": piac.uid_hash})
	if not ok:
		push_error(DBProvider.sql.error_message)
		return {}

	var generators: Dictionary[String, int]
	for d: Dictionary in DBProvider.sql.query_result:
		generators[d["generator"]] = d["version"]

	return generators

func save_executed_generator(player: PiacInfo, generator_name: String, version: int) -> bool:
	var ok: bool =  DBProvider.sql.query_with_named_bindings("INSERT INTO piac_generators(uid_hash, generator, version) VALUES(:uid_hash, :generator, :version) ON CONFLICT DO UPDATE SET version = excluded.version", {
		"uid_hash": player.uid_hash,
		"generator": generator_name,
		"version": version,
	})

	if not ok:
		push_error("Query failed: ", DBProvider.sql.error_message)

	return ok
