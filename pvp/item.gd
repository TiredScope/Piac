@tool
class_name Item
extends PanelContainer

@export var highlighted: bool:
	set(value):
		highlighted = value
		_apply_style()

@export var selected: bool:
	set(value):
		selected = value
		_apply_style()

@export var slot_index: int:
	set(value):
		slot_index = value
		_apply_style()

@export var item_data: ItemData:
	set(value):
		item_data = value
		_apply_style()

@onready var _stylebox: StyleBoxFlat = get_theme_stylebox("panel") as StyleBoxFlat
@onready var _slot_index: Label = $SlotIndex
@onready var _icon: TextureRect = $MarginContainer/TextureRect
@onready var _tooltip: Control = $Tooltip
@onready var _tooltip_content: PanelContainer = $Tooltip/PanelContainer
@onready var _tooltip_label: Label = $Tooltip/PanelContainer/MarginContainer/Label

func _ready() -> void:
	_apply_style()

func _apply_style() -> void:
	if not is_inside_tree():
		return

	_slot_index.text = str(slot_index)

	if not item_data:
		_icon.texture = null
		_tooltip.visible = false
		return

	_icon.texture = item_data.icon
	_tooltip.visible = highlighted

	var item_tooltip: String = item_data.name

	if item_data.description != "":
		item_tooltip += "\r" + item_data.description

	item_tooltip += "\n\nSlot: " + ItemData.get_slot_name(item_data.slot)

	print(item_tooltip)
	_tooltip_label.text = item_tooltip
	call_deferred("_center_tooltip")

	_stylebox.border_color = Color.ORANGE if highlighted else Color.TRANSPARENT
	_stylebox.bg_color = Color.GREEN if selected else Color.TRANSPARENT

func _center_tooltip() -> void:
	_tooltip_content.position.x = -_tooltip_content.get_rect().size.x * 0.5
