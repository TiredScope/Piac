class_name MQ3Module
extends Module

const ID: String = "mq3"

class Values:
	var alcohol_detected: bool
	var value: int

signal received_values(message: Message, values: Values)
signal state_changed(message: Message, alcohol_detected: bool)

var _values: Dictionary[int, Values]
var _alcohol_detected: Dictionary[int, bool]

func _init(com: MiniCom) -> void:
	super(com)
	self._values = {}

func _on_message(m: Message) -> void:
	match m.type:
		Message.Type.M_MQ3_VALUES:
			var reader: MessageReader = m.reader()

			var values: Values = Values.new()

			values.alcohol_detected = reader.get_u8() != 0
			values.value = reader.get_u16()

			_values[m.discriminator] = values
			received_values.emit(m, values)
		Message.Type.M_MQ3_STATE_CHANGED:
			var reader: MessageReader = m.reader()

			var alcohol_detected: bool = reader.get_u8() != 0

			_alcohol_detected[m.discriminator] = alcohol_detected
			state_changed.emit(m, alcohol_detected)

func get_id() -> String:
	return ID

func set_reporting_delay(delay: int, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_MQ3_SET_REPORTING_DELAY, discriminator)
	builder.put_u32(delay)
	_com.send_message(builder.build())

func get_values(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> Values:
	if discriminator != Message.DEFAULT_DISCRIMINATOR:
		return _values.get(Message.DEFAULT_DISCRIMINATOR, Values.new())

	if len(_values) == 0:
		return Values.new()

	return _values.values()[0]
