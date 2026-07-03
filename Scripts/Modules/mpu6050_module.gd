class_name MPU6050Module
extends Module

const ID: String = "mpu6050"

class Values:
	var raw_acceleration: Vector3i
	var raw_gyroscope: Vector3i

	var acceleration: Vector3
	var gyroscope: Vector3

class CalibrationValues:
	var accel_offset: Vector3i
	var gyro_offset: Vector3i

enum AccelRange {
	FS_250 = 0x00,
	FS_500 = 0x01,
	FS_1000 = 0x02,
	FS_2000 = 0x03,
}

enum GyroRange {
	FS_2 = 0x00,
	FS_4 = 0x01,
	FS_8 = 0x02,
	FS_16 = 0x03,
}

const DEFAULT_ACCEL_RANGE: AccelRange = AccelRange.FS_2000
const DEFAULT_GYRO_RANGE: GyroRange = GyroRange.FS_8

signal received_values(message: Message, values: Values)
signal received_calibration_values(message: Message, values: CalibrationValues)

var _values: Dictionary[int, Values]
var _accel_ranges: Dictionary[int, AccelRange]
var _gyro_ranges: Dictionary[int, GyroRange]

func _init(com: MiniCom) -> void:
	super(com)
	self._values = {}

func _on_message(m: Message) -> void:
	match m.type:
		Message.Type.M_MPU6050_VALUES:
			var reader: MessageReader = m.reader()

			var values: Values = Values.new()

			var ax: int = reader.get_i16()
			var ay: int = reader.get_i16()
			var az: int = reader.get_i16()

			var gx: int = reader.get_i16()
			var gy: int = reader.get_i16()
			var gz: int = reader.get_i16()

			values.raw_acceleration = Vector3i(ax, ay, az)
			values.raw_gyroscope = Vector3i(gx, gy, gz)

			var accel_range: AccelRange = get_accel_range(m.discriminator)
			values.acceleration = Vector3(get_accel_value(ax, accel_range), get_accel_value(ay, accel_range), get_accel_value(az, accel_range))

			var gyro_range: GyroRange = get_gyro_range(m.discriminator)
			values.gyroscope = Vector3(get_gyro_value(ax, gyro_range), get_gyro_value(ay, gyro_range), get_gyro_value(az, gyro_range))

			_values[m.discriminator] = values
			received_values.emit(m, values)
		Message.Type.M_MPU6050_SET_CALIBRATION_VALUES:
			var reader: MessageReader = m.reader()

			var values: CalibrationValues = CalibrationValues.new()

			var x_accel_offset: int = reader.get_i16()
			var y_accel_offset: int = reader.get_i16()
			var z_accel_offset: int = reader.get_i16()

			var x_gyro_offset: int = reader.get_i16()
			var y_gyro_offset: int = reader.get_i16()
			var z_gyro_offset: int = reader.get_i16()

			values.accel_offset = Vector3i(x_accel_offset, y_accel_offset, z_accel_offset)
			values.gyro_offset = Vector3i(x_gyro_offset, y_gyro_offset, z_gyro_offset)

			received_calibration_values.emit(m, values)


func get_id() -> String:
	return ID

func set_reporting_delay(delay: int, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_MPU6050_SET_REPORTING_DELAY, discriminator)
	builder.put_u32(delay)
	_com.send_message(builder.build())

func set_ranges(accelerometer_range: AccelRange, gyroscope_range: GyroRange, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_MPU6050_SET_RANGES, discriminator)
	builder.put_u8(accelerometer_range)
	builder.put_u8(gyroscope_range)

	_accel_ranges[discriminator] = accelerometer_range
	_gyro_ranges[discriminator] = gyroscope_range

	_com.send_message(builder.build())

func start_calibration(num_loops: int, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_MPU6050_START_CALIBRATION, discriminator)
	builder.put_u8(num_loops)
	_com.send_message(builder.build())

func get_accel_range(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> AccelRange:
	if discriminator != Message.DEFAULT_DISCRIMINATOR:
		return _accel_ranges.get(Message.DEFAULT_DISCRIMINATOR, DEFAULT_ACCEL_RANGE)

	if len(_accel_ranges) == 0:
		return DEFAULT_ACCEL_RANGE

	return _accel_ranges.values()[0]

func get_gyro_range(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> GyroRange:
	if discriminator != Message.DEFAULT_DISCRIMINATOR:
		return _gyro_ranges.get(Message.DEFAULT_DISCRIMINATOR, DEFAULT_GYRO_RANGE)

	if len(_gyro_ranges) == 0:
		return DEFAULT_GYRO_RANGE

	return _gyro_ranges.values()[0]

func get_values(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> Values:
	if discriminator != Message.DEFAULT_DISCRIMINATOR:
		return _values.get(Message.DEFAULT_DISCRIMINATOR, Values.new())

	if len(_values) == 0:
		return Values.new()

	return _values.values()[0]

static func get_accel_value(value: int, accel_range: AccelRange) -> float:
	match accel_range:
		AccelRange.FS_250:
			return remap(value, -(1<<15), (1<<15)-1, -250, 250)
		AccelRange.FS_500:
			return remap(value, -(1<<15), (1<<15)-1, -500, 500)
		AccelRange.FS_1000:
			return remap(value, -(1<<15), (1<<15)-1, -1000, 1000)
		AccelRange.FS_2000:
			return remap(value, -(1<<15), (1<<15)-1, -2000, 2000)
		_:
			return 0

static func get_gyro_value(value: int, gyro_range: GyroRange) -> float:
	match gyro_range:
		GyroRange.FS_2:
			return remap(value, -(1<<15), (1<<15)-1, -2, 2)
		GyroRange.FS_4:
			return remap(value, -(1<<15), (1<<15)-1, -4, 4)
		GyroRange.FS_8:
			return remap(value, -(1<<15), (1<<15)-1, -8, 8)
		GyroRange.FS_16:
			return remap(value, -(1<<15), (1<<15)-1, -16, 16)
		_:
			return 0
