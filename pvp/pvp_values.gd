class_name PVPValues
extends Resource

static var POINTS_IN_DISTRIBUTION: int = 30

@export_range(PVPConstants.HP_MIN, PVPConstants.HP_MAX, 1) var hp: int
@export_range(PVPConstants.ATTACK_MIN, PVPConstants.ATTACK_MAX, 1) var attack: int
@export_range(PVPConstants.DEFENSE_MIN, PVPConstants.DEFENSE_MAX, 1) var defense: int
@export_range(PVPConstants.OBEDIENCE_MIN, PVPConstants.OBEDIENCE_MAX, 0.05) var obedience: float
@export_range(PVPConstants.TEMPO_MIN, PVPConstants.TEMPO_MAX, 1) var tempo: int
@export_range(PVPConstants.LUCK_MIN, PVPConstants.LUCK_MAX, 0.1) var luck: float

func _init(_hp: int, _attack: int, _defense: int, _obedience: float, _tempo: int, _luck: float) -> void:
	self.hp = _hp
	self.attack = _attack
	self.defense = _defense
	self.obedience = _obedience
	self.tempo = _tempo
	self.luck = _luck

static func generate_from_distribution(distribution: Array[int]) -> PVPValues:
	var sum: int = distribution.reduce(func (a: int, b: int) -> int:
		return a+b, 0)

	assert(sum == PVPConstants.POINTS_IN_DISTRIBUTION)

	var gen_hp: int = int(_generate_value(0, PVPConstants.HP_MIN, PVPConstants.HP_MAX))
	var gen_attack: int = int(_generate_value(0, PVPConstants.ATTACK_MIN, PVPConstants.ATTACK_MAX))
	var gen_defense: int = int(_generate_value(0, PVPConstants.DEFENSE_MIN, PVPConstants.DEFENSE_MAX))
	var gen_obedience: float = _generate_value(0, PVPConstants.OBEDIENCE_MIN, PVPConstants.OBEDIENCE_MAX)
	var gen_tempo: int = int(_generate_value(0, PVPConstants.TEMPO_MIN, PVPConstants.TEMPO_MAX))
	var gen_luck: float = _generate_value(0, PVPConstants.LUCK_MIN, PVPConstants.LUCK_MAX)

	return PVPValues.new(
		gen_hp,
		gen_attack,
		gen_defense,
		gen_obedience,
		gen_tempo,
		gen_luck,
	)

static func _generate_value(value: int, min_value: float, max_value: float) -> float:
	return remap(value, 0, PVPConstants.MAX_POINTS_PER_CATEGORY, min_value, max_value)

static func generate_distribution() -> Array[int]:
	var values: Array[int] = []
	values.resize(PVPConstants.NUM_STATS)
	values.fill(0)

	for _i: int in range(PVPConstants.POINTS_IN_DISTRIBUTION):
		var idx: int = randi_range(0, len(values)-1)
		values[idx] += 1

	return values
