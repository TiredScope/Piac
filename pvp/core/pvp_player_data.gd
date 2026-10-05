class_name PVPPlayerData
extends Resource

@export var value_distribution: Array[int]
@export var value_distribution_max: int

func _init() -> void:
	value_distribution = []
	value_distribution.resize(PVPConstants.get_num_stats())
	value_distribution.fill(0)


static func create_random() -> PVPPlayerData:
	var player_info: PVPPlayerData = PVPPlayerData.new()

	# Ensure we don't run into an infinite loop
	assert(len(player_info.value_distribution) * PVPConstants.STATS.max_points_per_category >= PVPConstants.STATS.total_points)

	var i: int = 0
	while i < PVPConstants.STATS.total_points:
		var idx: int = randi_range(0, len(player_info.value_distribution)-1)
		if player_info.value_distribution[idx] >= PVPConstants.STATS.max_points_per_category:
			continue

		player_info.value_distribution[idx] += 1
		i += 1

	return player_info
