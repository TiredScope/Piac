class_name PotentiometerModule
extends Module

const ID: String = "potentiometer"

signal received_value(message: Message, value: int)

var _value: Dictionary[int, int]

func _init(com: MiniCom) -> void:
	super(com)
	self._value = {}

func _on_message(m: Message) -> void:
	if m.type == Message.Type.M_POTENTIOMETER_VALUE:
		var reader: MessageReader = m.reader()
		var value: int = reader.get_u16()
		_value[m.discriminator] =  value
		received_value.emit(m, value)

func get_id() -> String:
	return ID

func set_reporting_delay(delay: int, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_POTENTIOMETER_SET_REPORTING_DELAY, discriminator)
	builder.put_u32(delay)
	_com.send_message(builder.build())

func get_value(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> bool:
	if discriminator != Message.DEFAULT_DISCRIMINATOR:
		return _value.get(Message.DEFAULT_DISCRIMINATOR, false)

	if len(_value) == 0:
		return false

	return _value.values()[0]
