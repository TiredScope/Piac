@tool
class_name PVPValues
extends Resource

@export var values: Dictionary[Stats.PVPStat, float]

var hp: float:
	get():
		return get_value(Stats.PVPStat.HP)

var attack: float:
	get():
		return get_value(Stats.PVPStat.ATTACK)

var defense: float:
	get():
		return get_value(Stats.PVPStat.DEFENSE)

var obedience: float:
	get():
		return get_value(Stats.PVPStat.OBEDIENCE)

var tempo: float:
	get():
		return get_value(Stats.PVPStat.TEMPO)

var luck: float:
	get():
		return get_value(Stats.PVPStat.LUCK)

func _init(_values: Dictionary[Stats.PVPStat, float] = _make_empty()) -> void:
	self.values = _values

func get_value(stat: Stats.PVPStat) -> float:
	return values.get(stat, 0.0)

func add(other: PVPValues) -> PVPValues:
	var new_values: Dictionary[Stats.PVPStat, float] = {}
	for stat: Stats.PVPStat in Stats.PVPStat.values():
		new_values[stat] = get_value(stat) + other.get_value(stat)
	return PVPValues.new(new_values)

# TODO: do we need this? Are values allowed to exceed their min and max values if boosted by bonuses?
func clamp_ranges() -> void:
	for stat: Stats.PVPStat in Stats.PVPStat.values():
		var info: StatInfo = PVPConstants.get_info(stat)
		values[stat] = clampf(get_value(stat), info.min_value, info.max_value)

static func generate_from_distribution(distribution: Array[int]) -> PVPValues:
	var sum: int = distribution.reduce(func (a: int, b: int) -> int:
		return a+b, 0)

	assert(len(distribution) == PVPConstants.get_num_stats())
	assert(sum == PVPConstants.STATS.totalPoints)

	var gen_values: Dictionary[Stats.PVPStat, float] = {}

	for stat: Stats.PVPStat in Stats.PVPStat.values():
		var info: StatInfo = PVPConstants.get_info(stat)
		var gen_value: float = _generate_value(distribution[stat], info.min_value, info.max_value)
		gen_values[stat] = gen_value

	return PVPValues.new(gen_values)

static func _generate_value(value: int, min_value: float, max_value: float) -> float:
	return remap(value, 0, PVPConstants.STATS.maxPointsPerCategory, min_value, max_value)

static func generate_distribution() -> Array[int]:
	var distribution: Array[int] = []
	distribution.resize(PVPConstants.get_num_stats())
	distribution.fill(0)

	for _i: int in range(PVPConstants.STATS.totalPoints):
		var idx: int = randi_range(0, len(distribution)-1)
		distribution[idx] += 1

	return distribution

static func _make_empty() -> Dictionary[Stats.PVPStat, float]:
	var empty_values: Dictionary[Stats.PVPStat, float] = {}
	for stat: Stats.PVPStat in Stats.PVPStat.values():
		empty_values[stat] = 0
	return empty_values
