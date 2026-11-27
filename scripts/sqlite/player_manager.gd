class_name PlayerManager
extends Node

func get_piac(uid_hash: PackedByteArray) -> PiacInfo:
	var ok: bool = DBProvider.sql.query_with_named_bindings("SELECT * FROM piac WHERE uid_hash = :uid_hash;", {"uid_hash": uid_hash})
	if not ok:
		push_error("Query failed: ", DBProvider.sql.error_message)
		return null

	if DBProvider.sql.query_result.is_empty():
		return null

	var result: Dictionary = DBProvider.sql.query_result[0]
	var piac: PiacInfo = PiacInfo.new()
	piac.uid_hash = uid_hash
	piac.uid = result["uid"] as PackedByteArray
	piac.pid = result["pid"] as int
	piac.name = result["name"] as String
	if not TraitGenerator.generate_traits(piac):
		# TODO: this should return an error, not nothing
		return null

	return piac

func create_new_piac(uid: PackedByteArray, player_name: String) -> PiacInfo:
	var piac: PiacInfo = PiacInfo.new()
	piac.uid = uid
	piac.pid = RandomNumberGenerator.new().randi()
	piac.uid_hash = TraitGenerator.generate_hash(uid)
	piac.name = player_name

	if not save_piac(piac):
		return null

	if not TraitGenerator.generate_traits(piac):
		# TODO: this should return an error, not nothing
		return null

	return piac

func save_piac(piac: PiacInfo) -> bool:
	var ok: bool = DBProvider.sql.insert_row("piac", {
		"uid_hash": piac.uid_hash,
		"uid": piac.uid,
		"pid": piac.pid,
		"name": piac.name,
	})
	print("OK=",ok)
	return ok

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

func save_executed_generator(piac: PiacInfo, generator_name: String, version: int) -> bool:
	var ok: bool =  DBProvider.sql.query_with_named_bindings("INSERT INTO piac_generators(uid_hash, generator, version) VALUES(:uid_hash, :generator, :version) ON CONFLICT DO UPDATE SET version = excluded.version", {
		"uid_hash": piac.uid_hash,
		"generator": generator_name,
		"version": version,
	})

	if not ok:
		push_error("Query failed: ", DBProvider.sql.error_message)

	return ok

func get_pvp_player_data(piac: PiacInfo) -> PVPPlayerData:
	var ok: bool = DBProvider.sql.query_with_named_bindings("SELECT * FROM pvp_player_data WHERE uid_hash = :uid_hash", {"uid_hash": piac.uid_hash})
	if not ok:
		push_error("Query failed: ", DBProvider.sql.error_message)
		return null

	if DBProvider.sql.query_result.is_empty():
		return null

	var result: Dictionary = DBProvider.sql.query_result[0]
	var data: PVPPlayerData = PVPPlayerData.new()
	var value_distribution: Array[int] = []
	value_distribution.assign(Array((result["value_distribution"] as String).split(",")).map(func (v: String) -> int: return int(v)))
	data.value_distribution = value_distribution
	data.value_distribution_max = result["value_distribution_max"] as int
	return data


func save_pvp_player_data(piac: PiacInfo, data: PVPPlayerData) -> bool:
	return DBProvider.sql.insert_row("pvp_player_data", {
		"uid_hash": piac.uid_hash,
		"value_distribution": ",".join(data.value_distribution.map(str)),
		"value_distribution_max": data.value_distribution_max,
	})
