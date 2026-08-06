class_name ThermistorModule
extends Module

const ID: String = "thermistor"

signal received_value(message: Message, value: int)

var _value: Dictionary[int, int]

func _init(com: MiniCom) -> void:
	super(com)
	self._value = {}

func _on_message(m: Message) -> void:
	if m.type == Message.Type.M_THERMISTOR_VALUE:
		var reader: MessageReader = m.reader()
		var value: int = reader.get_u16() != 0
		_value[m.discriminator] = value
		received_value.emit(m, value)

func get_id() -> String:
	return ID

func get_value(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> bool:
	if discriminator != Message.DEFAULT_DISCRIMINATOR:
		return _value.get(Message.DEFAULT_DISCRIMINATOR, false)

	if len(_value) == 0:
		return false

	return _value.values()[0]
