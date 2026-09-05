class_name DS3231Module
extends Module

const ID: String = "ds3231"

class ParsedTime:
	var year: int
	var month: int
	var day: int
	var hour: int
	var minute: int
	var second: int

	func _to_string() -> String:
		return "%04d-%02d-%02d %02d:%02d:%02d" % [year, month, day, hour, minute, second]

	static func parse(unix_time: int) -> ParsedTime:
		var dict: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time)

		var t: ParsedTime = ParsedTime.new()
		t.year = dict["year"] as int
		t.month = dict["month"] as int
		t.day = dict["day"] as int
		t.hour = dict["hour"] as int
		t.minute = dict["minute"] as int
		t.second = dict["second"] as int

		return t

class Values:
	var unix_time: int
	var parsed_time: ParsedTime
	var local_parsed_time: ParsedTime

signal received_values(message: Message, values: Values)

var _values: Dictionary[int, Values]

func _init(com: MiniCom) -> void:
	super(com)
	self._values = {}

func _on_message(m: Message) -> void:
	if m.type == Message.Type.M_DS3231_VALUES:
		var reader: MessageReader = m.reader()

		var values: Values = Values.new()

		values.unix_time = reader.get_u32()
		values.parsed_time = ParsedTime.parse(values.unix_time)

		var tz_info: Dictionary = Time.get_time_zone_from_system()
		values.local_parsed_time = ParsedTime.parse(values.unix_time + (tz_info["bias"] as int * 60))

		_values[m.discriminator] = values
		received_values.emit(m, values)

func get_id() -> String:
	return ID

func set_reporting_delay(delay: int, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_DS3231_SET_REPORTING_DELAY, discriminator)
	builder.put_u32(delay)
	_com.send_message(builder.build())

func set_time(time: int, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_DS3231_SET_TIME, discriminator)
	builder.put_u32(time)
	_com.send_message(builder.build())

func get_values(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> Values:
	if discriminator != Message.DEFAULT_DISCRIMINATOR:
		return _values.get(Message.DEFAULT_DISCRIMINATOR, Values.new())

	if len(_values) == 0:
		return Values.new()

	return _values.values()[0]
