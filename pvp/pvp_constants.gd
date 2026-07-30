extends Node

enum PVPStat {
	HP,
	ATTACK,
	DEFENSE,
	OBEDIENCE,
	TEMPO,
	LUCK,
}

const MAX_POINTS_PER_CATEGORY: int = 10
const POINTS_IN_DISTRIBUTION: int = 30
const NUM_STATS: int = 6

const HP_MIN: int = 80
const HP_MAX: int = 100
const ATTACK_MIN: int = 8
const ATTACK_MAX: int = 15
const DEFENSE_MIN: int = 4
const DEFENSE_MAX: int = 10
const OBEDIENCE_MIN: float = 0.5
const OBEDIENCE_MAX: float = 0.8
const TEMPO_MIN: int = 1
const TEMPO_MAX: int = 10
const LUCK_MIN: float = 2
const LUCK_MAX: float = 3
