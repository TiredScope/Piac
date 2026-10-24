class_name DatabaseProvider
extends Node

var sql: SQLite

class Migration:
	var name: String
	var migrate: Callable

	func _init(p_name: String, p_migrate: Callable) -> void:
		self.name = p_name
		self.migrate = p_migrate

var MIGRATIONS: Array[Migration] = [
	Migration.new(
		"001_initial_setup",
		Migrations.migrate_001_initial_setup,
	)
]

func _ready() -> void:
	sql = SQLite.new()
	sql.path = "user://main"
	sql.open_db()
	apply_migrations()

func _exit_tree() -> void:
	sql.close_db()

func apply_migrations() -> void:
	sql.create_table("migrations", {
		"migration_name": {
			"data_type": "text",
			"primary_key": true,
			"not_null": true,
		}
	})

	for migration: Migration in MIGRATIONS:
		var success: bool = sql.query_with_named_bindings("SELECT TRUE FROM migrations WHERE migration_name = :name;", {"name": migration.name})
		if not success:
			print("Failed to check migration ", migration.name)

		if len(sql.query_result) == 0:
			print("Perfoming migration ", migration.name)

			sql.query("BEGIN TRANSACTION;")

			var ok: bool = migration.migrate.call(sql)
			if not ok:
				print("Failed to apply migration ", migration.name)
				sql.query("ROLLBACK TRANSACTION;")

			sql.insert_row("migrations", {"migration_name": migration.name})
			sql.query("END TRANSACTION;")
