@tool
class_name Stats
extends Resource

enum PVPStat {
	HP,
	ATTACK,
	DEFENSE,
	OBEDIENCE,
	TEMPO,
	LUCK,
}

@export_group("Generation")
@export var maxPointsPerCategory: int = 10
@export var totalPoints: int = 30

@export_group("Info")
@export var info: Dictionary[PVPStat, StatInfo] = _make_empty()

func _make_empty() -> Dictionary[PVPStat, StatInfo]:
	var empty_values: Dictionary[PVPStat, StatInfo] = {}
	for stat: PVPStat in PVPStat.values():
		empty_values[stat] = StatInfo.new()
	return empty_values
