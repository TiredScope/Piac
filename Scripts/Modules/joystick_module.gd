class_name JoystickModule
extends Module

const ID: String = "joystick"

class Values:
	var sw: bool
	var x: float
	var y: float

signal received_values(message: Message, x: float, y: float, sw: bool)

var _com: MiniCom
var _values: Values

func _init(com: MiniCom) -> void:
	self._com = com
	self._com.message_received.connect(_on_message)
	self._values = Values.new()

func _on_message(m: Message) -> void:
	if m.type == Message.Type.M_JOYSTICK_VALUES:
		var reader: MessageReader = m.reader()
		_values.x = reader.get_f32()
		_values.y = reader.get_f32()
		_values.sw = reader.get_u8() == 0 # low is pressed
		received_values.emit(m, _values.x, _values.y, _values.sw)

func get_id() -> String:
	return ID

func get_values() -> Values:
	return self._values
