extends Control

var first_player: bool
var picked_items: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _handle_keypad(key: int) -> void:
	$HBoxContainer/LeftConfiguration/MarginContainer/MainPanel/MarginContainer/VBoxContainer/GridContainer/Item2.highlighted = true
	print("Pressed key ", key)

func _unhandled_input(event: InputEvent) -> void:
	for i: int in range(10):
		if event.is_action_pressed("simulate_keypad_%d" % i):
			_handle_keypad(i)
			return

func _on_keypad_key_pressed(_message: Message, key: String) -> void:
	if not key.is_valid_int():
		return

	_handle_keypad(int(key))
