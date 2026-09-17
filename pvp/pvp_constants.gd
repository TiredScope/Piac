extends Node

const STATS: Stats = preload("res://Resources/stats.tres")
const ITEMS: Items = preload("res://Resources/items.tres")

func get_info(stat: Stats.PVPStat) -> StatInfo:
	return STATS.info[stat]

func get_num_stats() -> int:
	return len(STATS.info)
