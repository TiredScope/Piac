class_name StatInfo
extends Resource

enum PVPStat {
	HP,
	ATTACK,
	DEFENSE,
	OBEDIENCE,
	TEMPO,
	LUCK,
}

@export var name: String
@export var min_value: float
@export var max_value: float
