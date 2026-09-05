@tool
class_name PVPConfiguration
extends Control

@export var title_text: String:
	set(value):
		title_text = value
		_apply_style()

@export var highlighted: bool:
	set(value):
		highlighted = value
		_apply_style()

@export var player_ready: bool:
	set(value):
		player_ready = value
		_apply_style()

@onready var _panel: PanelContainer = $MarginContainer/MainPanel
@onready var _stylebox: StyleBoxFlat = _panel.get_theme_stylebox("panel") as StyleBoxFlat
@onready var _label: Label = %Label
@onready var _select_item: Label = %SelectItem
@onready var _player_ready: Label = %PlayerReady

func _ready() -> void:
	_apply_style()

func _apply_style() -> void:
	if not is_inside_tree():
		return

	_label.text = title_text

	_select_item.visible = highlighted
	_stylebox.border_color = Color.ORANGE if highlighted else Color.TRANSPARENT
	_player_ready.visible = player_ready

func get_inventory() -> Inventory:
	return %Inventory
