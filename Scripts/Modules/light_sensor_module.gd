class_name LightSensorModule
extends Module

const ID: String = "light_sensor"

signal received_value(message: Message, value: int)

var _com: MiniCom
var _value: Dictionary[int, int]

func _init(com: MiniCom) -> void:
	self._com = com
	self._com.message_received.connect(_on_message)
	self._value = {}

func _on_message(m: Message) -> void:
	if m.type == Message.Type.M_LIGHTSENSOR_VALUE:
		var reader: MessageReader = m.reader()
		var value: int = reader.get_u16() != 0
		_value[m.discriminator] = value
		received_value.emit(m, value)

func get_id() -> String:
	return ID

func get_distance(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> bool:
	if discriminator != Message.DEFAULT_DISCRIMINATOR:
		return _value.get(Message.DEFAULT_DISCRIMINATOR, false)

	if len(_value) == 0:
		return false

	return _value.values()[0]
