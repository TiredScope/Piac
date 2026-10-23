class_name NunchukModule
extends Module

const ID: String = "nunchuk"

class Values:
	var joy_x: int
	var joy_y: int
	var roll_angle: float
	var pitch_angle: float
	var accel_x: int
	var accel_y: int
	var accel_z: int
	var button_c: bool
	var button_z: bool

	func _to_string() -> String:
		var buttons: String = ("C" if button_c else "-") + ("Z" if button_z else "-")
		return "[Joystick: %3s/%3s, Roll: %6.2f, Pitch: %6.2f, Accel: %4s/%4s/%4s, Buttons: %s]" % [joy_x, joy_y, roll_angle, pitch_angle, accel_x, accel_y, accel_z, buttons]

signal received_values(message: Message, values: Values)

var _values: Dictionary[int, Values] = {}

func _on_message(m: Message) -> void:
	if m.type == Message.Type.M_NUNCHUK_VALUES:
		var reader: MessageReader = m.reader()

		var values: Values = Values.new()
		values.joy_x = reader.get_u8()
		values.joy_y = reader.get_u8()
		values.roll_angle = reader.get_f32()
		values.pitch_angle = reader.get_f32()
		values.accel_x = reader.get_u16()
		values.accel_y = reader.get_u16()
		values.accel_z = reader.get_u16()
		values.button_c = reader.get_u8() != 0
		values.button_z = reader.get_u8() != 0

		_values[m.discriminator] = values
		received_values.emit(m, _values)

func get_id() -> String:
	return ID

func get_values(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> Values:
	return _get_value(_values, discriminator, Values.new())
