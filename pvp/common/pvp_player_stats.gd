class_name PVPPlayerStats
extends PanelContainer

@onready var _normal: ProgressBar = %StatusBars/Normal
@onready var _crit: ProgressBar = %StatusBars/Crit
@onready var _block: ProgressBar = %StatusBars/Block
@onready var _hp: ProgressBar = %HP
@onready var _radar_chart: RadarChart = %RadarChart

func show_values(player: PVPFight.PVPPlayer) -> void:
	_hp.max_value = player.values.hp
	_hp.value = player.hp
	_normal.value = player.attack_values.normal
	_crit.value = player.attack_values.crit
	_block.value = player.attack_values.block

	print(player.data.value_distribution)
	var float_values: Array[float] = []
	for i: int in player.data.value_distribution:
		float_values.push_back(i)
	_radar_chart.values = float_values
	_radar_chart.max_value = PVPConstants.STATS.max_points_per_category
