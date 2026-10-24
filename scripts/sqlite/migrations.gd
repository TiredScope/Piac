class_name Migrations

static func migrate_001_initial_setup(sql: SQLite) -> bool:
	var ok: bool = sql.create_table("piac", {
		"uid_hash": { # SHA256 Hash of NFC UID
			"data_type": "blob",
			"primary_key": true,
			"not_null": true,
		},
		"uid": { # NFC UID
			"data_type": "blob",
			"unique": true,
		},
		"pid": { # Player id
			"data_type": "blob",
			"unique": true,
		},
		"name": { # Player name
			"data_type": "text",
		},
	})

	if not ok:
		return false

	#sql.create_table("piac_personality_values", {
	#})

	sql.create_table("piac_generators", {
		"uid_hash": {
			"data_type": "blob",
			"primary_key": true,
			"not_null": true,
		},
		"generator": {
			"data_type": "text",
			"primary_key": true,
			"not_null": true,
		},
		"version": {
			"data_type": "int",
			"not_null": true,
		},
	})

	return true
