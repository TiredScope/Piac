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

@export var maxPointsPerCategory: int = 10
@export var totalPoints: int = 30
@export var info: Dictionary[PVPStat, StatInfo]
