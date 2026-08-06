class_name DHT22Module
extends Module

const ID: String = "dht22"

class Values:
	var temperature: float
	var humidity: float

signal received_values(message: Message, values: Values)

var _values: Dictionary[int, Values]

func _init(com: MiniCom) -> void:
	super(com)
	self._values = {}

func _on_message(m: Message) -> void:
	if m.type == Message.Type.M_DHT22_VALUES:
		var reader: MessageReader = m.reader()

		var values: Values = Values.new()

		values.temperature = reader.get_f32()
		values.humidity = reader.get_f32()

		_values[m.discriminator] = values
		received_values.emit(m, values)

func get_id() -> String:
	return ID

func set_reporting_delay(delay: int, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_DHT22_SET_REPORTING_DELAY, discriminator)
	builder.put_u32(delay)
	_com.send_message(builder.build())

func get_values(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> Values:
	if discriminator != Message.DEFAULT_DISCRIMINATOR:
		return _values.get(Message.DEFAULT_DISCRIMINATOR, Values.new())

	if len(_values) == 0:
		return Values.new()

	return _values.values()[0]
