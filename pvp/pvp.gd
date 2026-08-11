extends Control

@export var num_items: int = 3

var first_player: bool = true
var picked_items: int

var _packed_pvp_fight: PackedScene = preload("res://pvp/pvp_fight.tscn")

@onready var left_config: PVPConfiguration = $HBoxContainer/LeftConfiguration
@onready var right_config: PVPConfiguration = $HBoxContainer/RightConfiguration

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_highlight()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _handle_keypad(key: int) -> void:
	var config: PVPConfiguration = get_config(first_player)

	var inv: Inventory = config.get_inventory()
	var selection: int = inv.get_highlighted_item()
	var to_select: int = key - 1

	if to_select == -1: # Pressed 0 -> Done
		config.player_ready = true
		if get_config(not first_player).player_ready:
			config.highlighted = false
			await get_tree().create_timer(3).timeout
			_selection_done()
			return

		first_player = not first_player
		_update_highlight()
	if selection == -1 or selection != to_select:
		inv.highlight_item(to_select)
	elif _is_selection_valid(inv, to_select):
		inv.set_selected(to_select, true)
		inv.highlight_item(-1)

		# TODO: Continue if done

		if not get_config(not first_player).player_ready:
			first_player = not first_player

		_update_highlight()
	print("Pressed key ", key)

func _is_selection_valid(inv: Inventory, slot: int) -> bool:
	var selected_item: Item = inv.get_item(slot)
	if not selected_item or not selected_item.item_data:
		return false

	var occupied_slots: Array[ItemData.Slot] = []
	for i: int in inv.get_selected_items():
		var item: Item = inv.get_item(i)
		if not item or not item.item_data:
			continue

		occupied_slots.push_back(item.item_data.slot)

	return not inv.get_selected_items().has(slot) and not occupied_slots.has(selected_item.item_data.slot)

func _can_player_select_anything(inv: Inventory) -> bool:
	for i: int in range(Inventory.INVENTORY_SIZE):
		if not inv.get_selected_items().has(i) and _is_selection_valid(inv, i):
			return true
	return false

func get_config(for_first_player: bool) -> PVPConfiguration:
	return left_config if for_first_player else right_config

func _update_highlight() -> void:
	left_config.highlighted = false
	right_config.highlighted = false
	get_config(first_player).highlighted = true

func _selection_done() -> void:
	var pvp_fight: PVPFight = _packed_pvp_fight.instantiate()
	get_tree().change_scene_to_node(pvp_fight)

func _unhandled_input(event: InputEvent) -> void:
	for i: int in range(10):
		if event.is_action_pressed("simulate_keypad_%d" % i):
			_handle_keypad(i)
			return

func _on_keypad_key_pressed(_message: Message, key: String) -> void:
	if not key.is_valid_int():
		return

	_handle_keypad(int(key))
