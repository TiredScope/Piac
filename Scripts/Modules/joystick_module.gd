class_name JoystickModule
extends Module

const ID: String = "joystick"

class Values:
	var sw: bool
	var x: float
	var y: float

signal received_values(message: Message, x: float, y: float, sw: bool)

var _values: Dictionary[int, Values]

func _init(com: MiniCom) -> void:
	super(com)
	self._values = {}

func _on_message(m: Message) -> void:
	if m.type == Message.Type.M_JOYSTICK_VALUES:
		var reader: MessageReader = m.reader()
		var values := Values.new()
		values.x = reader.get_f32()
		values.y = reader.get_f32()
		values.sw = reader.get_u8() == 0 # low is pressed
		_values[m.discriminator] = values
		received_values.emit(m, values.x, values.y, values.sw)

func get_id() -> String:
	return ID

func get_values(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> Values:
	if discriminator != Message.DEFAULT_DISCRIMINATOR:
		return self._values.get(discriminator, Values.new())

	if len(self._values) == 0:
		return Values.new()

	return self._values.values()[0]
