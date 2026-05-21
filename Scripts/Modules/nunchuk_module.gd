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

var _com: MiniCom
var _values: Values

func _init(com: MiniCom) -> void:
	self._com = com
	self._com.message_received.connect(_on_message)
	self._values = Values.new()

func _on_message(m: Message) -> void:
	if m.type == Message.Type.M_NUNCHUK_VALUES:
		var reader: MessageReader = m.reader()
		_values.joy_x = reader.get_u8()
		_values.joy_y = reader.get_u8()
		_values.roll_angle = reader.get_f32()
		_values.pitch_angle = reader.get_f32()
		_values.accel_x = reader.get_u16()
		_values.accel_y = reader.get_u16()
		_values.accel_z = reader.get_u16()
		_values.button_c = reader.get_u8() != 0
		_values.button_z = reader.get_u8() != 0
		received_values.emit(m, _values)

func get_id() -> String:
	return ID

func get_values() -> Values:
	return self._values
