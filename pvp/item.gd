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

@export var item_data: ItemData

@onready var _stylebox: StyleBoxFlat = get_theme_stylebox("panel") as StyleBoxFlat

func _ready() -> void:
	_apply_style()

func _apply_style() -> void:
	if not is_inside_tree():
		return

	_stylebox.border_color = Color.ORANGE if highlighted else Color.TRANSPARENT
	_stylebox.bg_color = Color.GREEN if selected else Color.TRANSPARENT
