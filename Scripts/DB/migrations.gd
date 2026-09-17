class_name Migrations

static func migrate_001_initial_setup(sql: SQLite) -> bool:
	var ok: bool = sql.create_table("piac", {
		"uid_hash": {
			"data_type": "blob",
			"primary_key": true,
			"not_null": true,
		},
		"uid": {
			"data_type": "blob",
			"unique": true,
		},
		"name": {
			"data_type": "text",
		}
	})

	if not ok:
		return false

	#sql.create_table("piac_personality_values", {
	#})

	return true
