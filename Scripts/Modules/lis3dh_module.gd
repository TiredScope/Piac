class_name LIS3DHModule
extends Module

const ID: String = "lis3dh"

class Values:
	var acceleration: Vector3

enum AccelRange {
	RANGE_2_G = 0b00,
	RANGE_4_G = 0b01,
	RANGE_8_G = 0b10,
	RANGE_16_G = 0b11,
}

enum DataRate {
	RATE_400_HZ = 0b0111, #  400Hz
	RATE_200_HZ = 0b0110, #  200Hz
	RATE_100_HZ = 0b0101, #  100Hz
	RATE_50_HZ = 0b0100,  #   50Hz
	RATE_25_HZ = 0b0011,  #   25Hz
	RATE_10_HZ = 0b0010,  # 10 Hz
	RATE_1_HZ = 0b0001,   # 1 Hz
	RATE_POWERDOWN = 0,
	RATE_LOWPOWER_1K6HZ = 0b1000,
	RATE_LOWPOWER_5KHZ = 0b1001,
}

enum PerformanceMode {
	MODE_LOW_POWER = 0x0,
	MODE_NORMAL = 0x1,
	MODE_HIGH_RESOLUTION = 0x2,
}

const DEFAULT_RANGE: AccelRange = AccelRange.RANGE_8_G
const DEFAULT_DATA_RATE: DataRate = DataRate.RATE_10_HZ
const DEFAULT_PERFORMANCE_MODE: PerformanceMode = PerformanceMode.MODE_NORMAL

signal received_values(message: Message, values: Values)

var _values: Dictionary[int, Values]
var _accel_ranges: Dictionary[int, AccelRange]
var _data_rates: Dictionary[int, DataRate]
var _performance_modes: Dictionary[int, PerformanceMode]

func _init(com: MiniCom) -> void:
	super(com)
	self._values = {}
	self._accel_ranges = {}
	self._data_rates = {}
	self._performance_modes = {}

func _on_message(m: Message) -> void:
	match m.type:
		Message.Type.M_LIS3DH_VALUES:
			var reader: MessageReader = m.reader()

			var values: Values = Values.new()

			var ax: float = reader.get_f32()
			var ay: float = reader.get_f32()
			var az: float = reader.get_f32()

			values.acceleration = Vector3(ax, ay, az)

			_values[m.discriminator] = values
			received_values.emit(m, values)


func get_id() -> String:
	return ID

func set_reporting_delay(delay: int, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_LIS3DH_SET_REPORTING_DELAY, discriminator)
	builder.put_u32(delay)
	_com.send_message(builder.build())

func set_params(data_rate: DataRate, performance_mode: PerformanceMode, accelerometer_range: AccelRange, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_LIS3DH_SET_PARAMS, discriminator)
	builder.put_u8(data_rate)
	builder.put_u8(performance_mode)
	builder.put_u8(accelerometer_range)

	_data_rates[discriminator] = data_rate
	_performance_modes[discriminator] = performance_mode
	_accel_ranges[discriminator] = accelerometer_range

	_com.send_message(builder.build())

func get_values(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> Values:
	if discriminator != Message.DEFAULT_DISCRIMINATOR:
		return _values.get(Message.DEFAULT_DISCRIMINATOR, Values.new())

	if len(_values) == 0:
		return Values.new()

	return _values.values()[0]
