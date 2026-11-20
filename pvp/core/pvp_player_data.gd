class_name PVPPlayerData
extends Resource

@export var value_distribution: Array[int]
@export var value_distribution_max: int

static var GENERATOR: ContentRegistry.AttributeGenerator = ContentRegistry.AttributeGenerator.new(
	"pvp",
	generate_data,
	ContentRegistry.RandomType.PLAYER_RANDOM,
	0
)

func _init() -> void:
	value_distribution = []
	value_distribution.resize(PVPConstants.get_num_stats())
	value_distribution.fill(0)
	value_distribution_max = PVPConstants.STATS.max_points_per_category


static func create_random(rng: RandomNumberGenerator) -> PVPPlayerData:
	var player_info: PVPPlayerData = PVPPlayerData.new()

	# Ensure we don't run into an infinite loop
	assert(len(player_info.value_distribution) * PVPConstants.STATS.max_points_per_category >= PVPConstants.STATS.total_points)

	var i: int = 0
	while i < PVPConstants.STATS.total_points:
		var idx: int = rng.randi_range(0, len(player_info.value_distribution)-1)
		if player_info.value_distribution[idx] >= PVPConstants.STATS.max_points_per_category:
			continue

		player_info.value_distribution[idx] += 1
		i += 1

	return player_info

static func generate_data(piac: PiacInfo, rng: RandomNumberGenerator) -> bool:
	var data: PVPPlayerData = PiacPlayerManager.get_pvp_player_data(piac)
	if data != null:
		return true

	data = create_random(rng)
	return PiacPlayerManager.save_pvp_player_data(piac, data)
