@tool
class_name ItemData
extends Resource

enum Slot {
	HEAD,
	TOOL,
	ACCESSORY,
	FEET,
}

@export var id: String = "new_item"
@export var name: String = "Neues Item"
@export var slot: Slot = Slot.HEAD
@export var icon: Texture2D = preload("res://icon.svg")
@export_multiline var description: String = ""

@export var bonus: PVPValues = PVPValues.new()
