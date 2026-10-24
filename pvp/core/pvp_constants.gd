extends Node

const STATS: Stats = preload("res://resources/stats.tres")
const ITEMS: Items = preload("res://resources/items.tres")

func get_info(stat: Stats.PVPStat) -> StatInfo:
	return STATS.info[stat]

func get_num_stats() -> int:
	return len(STATS.info)
