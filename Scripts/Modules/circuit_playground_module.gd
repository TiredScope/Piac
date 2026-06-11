class_name CircuitPlaygroundModule
extends Module

const ID: String = "circuit_playground"

class Buttons:
	var left: bool
	var right: bool
	var slide_switch: bool

class CapacitiveTouchValues:
	var _values: Dictionary[CapacitiveTouchPin, int]

	func get_value(pin: CapacitiveTouchPin) -> int:
		return _values.get(pin, 0)

class AccelerometerValues:
	var x: float
	var y: float
	var z: float

enum Component {
	BUTTONS,
	CAPACITIVE_TOUCH,
	ACCELEROMETER,
	TEMPERATURE,
	LIGHT,
	SOUND,
}

enum CapacitiveTouchPin {
	P0 = 0,
	P1 = 1,
	P2 = 2,
	P3 = 3,
	P6 = 6,
	P9 = 9,
	P10 = 10,
	P12 = 12,
}

signal buttons_received(message: Message, buttons: Buttons)
signal capacitive_touch_received(message: Message, values: CapacitiveTouchValues)
signal accelerometer_received(message: Message, values: AccelerometerValues)
signal temperature_received(message: Message, value: float)
signal light_received(message: Message, value: int)
signal sound_received(message: Message, value: int)

var _capacitive_touch_pins: Dictionary[int, int]

var _buttons: Dictionary[int, Buttons]
var _capacitive_touch: Dictionary[int, CapacitiveTouchValues]
var _accelerometer: Dictionary[int, AccelerometerValues]
var _temperature: Dictionary[int, float]
var _light: Dictionary[int, int]
var _sound: Dictionary[int, int]

func _on_message(m: Message) -> void:
	match m.type:
		Message.Type.M_CIRCUITPLAYGROUND_BUTTONS:
			var reader: MessageReader = m.reader()

			var state: int = reader.get_u8()
			var buttons: Buttons = Buttons.new()
			buttons.slide_switch = (state & (1 << 2)) != 0
			buttons.left = (state & (1 << 1)) != 0
			buttons.right = (state & (1 << 0)) != 0
			_buttons[m.discriminator] = buttons
			buttons_received.emit(m, buttons)
		Message.Type.M_CIRCUITPLAYGROUND_CAPACITIVE_TOUCH:
			var reader: MessageReader = m.reader()

			var values: CapacitiveTouchValues = CapacitiveTouchValues.new()

			var pins: int = reader.get_u8()
			for p: CapacitiveTouchPin in CapacitiveTouchPin.values():
				var idx: int = CapacitiveTouchPin.values().find(p)
				if pins & (1 << idx) != 0:
					values._values[p] = reader.get_u16()

			_capacitive_touch[m.discriminator] = values
			capacitive_touch_received.emit(m, values)
		Message.Type.M_CIRCUITPLAYGROUND_ACCELEROMETER:
			var reader: MessageReader = m.reader()

			var values: AccelerometerValues = AccelerometerValues.new()
			values.x = reader.get_f32()
			values.y = reader.get_f32()
			values.z = reader.get_f32()

			_accelerometer[m.discriminator] = values
			accelerometer_received.emit(m, values)
		Message.Type.M_CIRCUITPLAYGROUND_TEMPERATURE:
			var reader: MessageReader = m.reader()

			var value: float = reader.get_f32()

			_temperature[m.discriminator] = value
			temperature_received.emit(m, value)
		Message.Type.M_CIRCUITPLAYGROUND_LIGHT:
			var reader: MessageReader = m.reader()

			var value: int = reader.get_u16()

			_light[m.discriminator] = value
			light_received.emit(m, value)
		Message.Type.M_CIRCUITPLAYGROUND_SOUND:
			var reader: MessageReader = m.reader()

			var value: int = reader.get_i16()

			_sound[m.discriminator] = value
			sound_received.emit(m, value)

func get_id() -> String:
	return ID

func set_reporting_delay(delay: int, components: Array[Component] = [], discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var value: int = 0

	if components.is_empty():
		components.assign(Component.values())

	for c: Component in components:
		value |= (1 << c)

	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_CIRCUITPLAYGROUND_SET_REPORTING_DELAY, discriminator)
	builder.put_u8(value)
	builder.put_u32(delay)
	_com.send_message(builder.build())

func set_reporting_mode(components: Array[Component], discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var value: int = 0

	for c: Component in components:
		value |= (1 << c)

	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_CIRCUITPLAYGROUND_SET_REPORTING_MODE, discriminator)
	builder.put_u8(value)
	_com.send_message(builder.build())

func set_capacitive_touch_pins(pins: Array[CapacitiveTouchPin], discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var value: int = 0

	for pin: CapacitiveTouchPin in pins:
		var idx: int = CapacitiveTouchPin.values().find(pin)
		value |= (1 << idx)

	_capacitive_touch_pins[discriminator] = value

	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_CIRCUITPLAYGROUND_SET_CAPACITIVE_TOUCH_PINS, discriminator)
	builder.put_u8(value)
	_com.send_message(builder.build())

func set_pixel(pixel: int, color: Color, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_CIRCUITPLAYGROUND_SET_PIXEL, discriminator)
	builder.put_u8(pixel)

	var argb32: int = color.to_argb32()
	builder.put_u8((argb32 >> 16) & 0xFF)
	builder.put_u8((argb32 >> 8) & 0xFF)
	builder.put_u8(argb32 & 0xFF)
	_com.send_message(builder.build())

func _get_value(dict: Dictionary, discriminator: int, default: Variant) -> Variant:
	if discriminator != Message.DEFAULT_DISCRIMINATOR:
		return dict.get(discriminator, default)

	if len(dict) == 0:
		return default

	return dict.values()[0]

func get_buttons(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> Buttons:
	return _get_value(_buttons, discriminator, Buttons.new())

func get_capacitive_touch(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> CapacitiveTouchValues:
	return _get_value(_capacitive_touch, discriminator, CapacitiveTouchValues.new())

func get_accelerometer(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> AccelerometerValues:
	return _get_value(_accelerometer, discriminator, AccelerometerValues.new())

func get_temperature(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> float:
	return _get_value(_temperature, discriminator, 0)

func get_light(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> int:
	return _get_value(_light, discriminator, 0)

func get_sound(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> int:
	return _get_value(_sound, discriminator, 0)
