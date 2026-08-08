extends Control

var first_player: bool = true
var picked_items: int

@onready var left_config: PVPConfiguration = $HBoxContainer/LeftConfiguration
@onready var right_config: PVPConfiguration = $HBoxContainer/RightConfiguration

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_highlight()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _handle_keypad(key: int) -> void:
	var config: PVPConfiguration = get_active_config()

	var inv: Inventory = config.get_inventory()
	var selection: int = inv.get_highlighted_item()
	var to_select: int = key - 1

	if selection == -1 or to_select == -1 or selection != to_select:
		inv.highlight_item(to_select)
	elif not inv.get_selected_items().has(to_select):
		inv.set_selected(to_select, true)
		inv.highlight_item(-1)
		first_player = not first_player
		_update_highlight()
	print("Pressed key ", key)

func get_active_config() -> PVPConfiguration:
	return left_config if first_player else right_config

func _update_highlight() -> void:
	left_config.highlighted = false
	right_config.highlighted = false
	get_active_config().highlighted = true

func _unhandled_input(event: InputEvent) -> void:
	for i: int in range(10):
		if event.is_action_pressed("simulate_keypad_%d" % i):
			_handle_keypad(i)
			return

func _on_keypad_key_pressed(_message: Message, key: String) -> void:
	if not key.is_valid_int():
		return

	_handle_keypad(int(key))
