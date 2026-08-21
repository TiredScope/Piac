class_name PVPPlayerStats
extends PanelContainer

@onready var _normal: ProgressBar = %StatusBars/Normal
@onready var _crit: ProgressBar = %StatusBars/Crit
@onready var _block: ProgressBar = %StatusBars/Block
@onready var _hp: ProgressBar = %HP

func show_values(player: PVPFight.PVPPlayer) -> void:
	_hp.max_value = player.values.hp
	_hp.value = player.hp
	_normal.value = player.attack_values.normal
	_crit.value = player.attack_values.crit
	_block.value = player.attack_values.block
