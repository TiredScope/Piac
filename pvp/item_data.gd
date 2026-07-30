class_name ItemData
extends Resource

# TODO: refactor

enum Slot {
	HEAD,
	TOOL,
	ACCESSORY,
	FEET,
}

@export var item_name: String = "Neues Item"
@export var equipment_slot: Slot = Slot.HEAD
@export_multiline var description: String = ""

@export var bonus: Dictionary[PVPConstants.PVPStat, int] = {
	PVPConstants.PVPStat.HP: 0,
	PVPConstants.PVPStat.ATTACK: 0,
	PVPConstants.PVPStat.DEFENSE: 0,
	PVPConstants.PVPStat.OBEDIENCE: 0,
	PVPConstants.PVPStat.TEMPO: 0,
}

@export_category("Boni in internen Punkten")
@export_range(0, 5, 1) var hp_bonus: int = 0
@export_range(0, 5, 1) var attack_bonus: int = 0
@export_range(0, 5, 1) var defense_bonus: int = 0
@export_range(0, 5, 1) var obedience_bonus: int = 0
@export_range(0, 5, 1) var tempo_bonus: int = 0
@export_range(0, 5, 1) var luck_bonus: int = 0


func get_bonus(stat_index: int) -> int:
	match stat_index:
		0: return hp_bonus
		1: return attack_bonus
		2: return defense_bonus
		3: return obedience_bonus
		4: return tempo_bonus
		5: return luck_bonus
	return 0


func slot_name() -> String:
	return ["Kopf", "Tool", "Accessoire", "Füße"][clampi(equipment_slot, 0, 3)]


func bonus_text() -> String:
	var names := ["HP", "Angriff", "Verteidigung", "Gehorsam", "Tempo", "Glück"]
	var parts: Array[String] = []
	for i in range(6):
		var bonus := get_bonus(i)
		if bonus > 0:
			parts.append("+%d %s" % [bonus, names[i]])
	return ", ".join(parts)
