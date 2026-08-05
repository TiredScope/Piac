@tool
extends Control

@export var highlighted: bool:
	set(value):
		highlighted = value
		_apply_highlight()

@onready var _panel: PanelContainer = $MarginContainer/MainPanel
@onready var _stylebox: StyleBoxFlat = _panel.get_theme_stylebox("panel") as StyleBoxFlat

func _ready() -> void:
	_apply_highlight()

func _apply_highlight() -> void:
	if not is_inside_tree():
		return

	_stylebox.border_color = Color.ORANGE if highlighted else Color.TRANSPARENT
