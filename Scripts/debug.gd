extends Node

var rfid: RFIDModule
var pulse_sensor: PulseSensorModule
var circuit_playground: CircuitPlaygroundModule
var dht22: DHT22Module
var mq3: MQ3Module
var keypad: SparkfunKeypadModule
var neoPixel: NeoPixelModule
var bme280: BME280Module
var mpu6050: MPU6050Module
var pressureSensor: PressureSensorModule
var potentiometer: PotentiometerModule
var light: LightSensorModule
var max4466: MAX4466Module
var scd41: SCD41Module
var lis3dh: LIS3DHModule

var t: float = 0
var lastChange: float = -1

func _init() -> void:
	Com.connected.connect(func(client: MiniCom.Client) -> void:
		debug_print("%s connected" % [client.get_port()])
	)

	Com.disconnected.connect(func(client: MiniCom.Client) -> void:
		debug_print("%s disconnected" % [client.get_port()])
		update_modules()
	)

	Com.message_received.connect(func(message: Message) -> void:
		if message.type in [Message.Type.M_NOP, Message.Type.M_DEBUG]:
			return

		debug_print("%s > %s" % [message.source.get_port(), message.to_string()])
	)

	Com.capabilities_received.connect(func(message: Message, capabilities: Array[MiniCom.ClientModule]) -> void:
		debug_print("%s has capabilities %s" % [message.source.get_port(), capabilities])
		update_modules()
	)

	Com.debug_print_received.connect(func(message: Message, text: String) -> void:
		debug_print("%s > [DEBUG] %s" % [message.source.get_port(), text])
	)

	Com.is_ready.connect(func(client: MiniCom.Client) -> void:
		debug_print("%s is ready" % [client.get_port()])
	)

	self.rfid = RFIDModule.new(Com)
	rfid.scanned.connect(func(message: Message, uid: PackedByteArray) -> void:
		debug_print("%s scanned tag with uid %s" % [message.source.get_port(), uid.hex_encode()])
		debug_print("Generated traits: %s" % [TraitGenerator.generate_traits(uid)])
	)

	self.pulse_sensor = PulseSensorModule.new(Com)
	pulse_sensor.heartbeat.connect(func(message: Message, bpm: int) -> void:
		debug_print("%s BPM: %s" % [message.source.get_port(), bpm])
	)

	self.circuit_playground = CircuitPlaygroundModule.new(Com)
	circuit_playground.init.connect(func(_client: MiniCom.Client, _discriminator: int) -> void:
		#circuit_playground.set_capacitive_touch_pins([CircuitPlaygroundModule.CapacitiveTouchPin.P12, CircuitPlaygroundModule.CapacitiveTouchPin.P0])
		#circuit_playground.set_reporting_delay(100, [CircuitPlaygroundModule.Component.CAPACITIVE_TOUCH])
		circuit_playground.set_reporting_mode([CircuitPlaygroundModule.Component.BUTTONS])
		circuit_playground.set_pixel(0, Color.AQUA)
	)

	circuit_playground.buttons_received.connect(func(message: Message, buttons: CircuitPlaygroundModule.Buttons) -> void:
		debug_print("%s Buttons: left=%s right=%s sw=%s" % [message.source.get_port(), "X" if buttons.left else "-", "X" if buttons.right else "-", "<-" if buttons.slide_switch else "->"])
	)

	circuit_playground.capacitive_touch_received.connect(func(message: Message, values: CircuitPlaygroundModule.CapacitiveTouchValues) -> void:
		var touch_str: Array[String]
		for p: CircuitPlaygroundModule.CapacitiveTouchPin in CircuitPlaygroundModule.CapacitiveTouchPin.values():
			touch_str.push_back("%s=%d" % [p, values.get_value(p)])

		debug_print("%s Capacitive Touch: %s" % [message.source.get_port(), ", ".join(touch_str)])
	)

	circuit_playground.accelerometer_received.connect(func(message: Message, values: CircuitPlaygroundModule.AccelerometerValues) -> void:
		debug_print("%s Accelerometer: %4.2f/%4.2f/%4.2f" % [message.source.get_port(), values.x, values.y, values.z])
	)

	circuit_playground.temperature_received.connect(func(message: Message, temperature: float) -> void:
		debug_print("%s Temperature: %f" % [message.source.get_port(), temperature])
	)

	circuit_playground.light_received.connect(func(message: Message, value: int) -> void:
		debug_print("%s Light: %f" % [message.source.get_port(), value])
	)

	circuit_playground.sound_received.connect(func(message: Message, value: int) -> void:
		debug_print("%s Sound: %f" % [message.source.get_port(), value])
	)

	self.dht22 = DHT22Module.new(Com)
	dht22.init.connect(func(_client: MiniCom.Client, discriminator: int) -> void:
		dht22.set_reporting_delay(5000, discriminator)
	)

	dht22.received_values.connect(func(message: Message, values: DHT22Module.Values) -> void:
		debug_print("%s DHT22 values: t=%4.2f h=%4.2f" % [message.source.get_port(), values.temperature, values.humidity])
	)

	self.mq3 = MQ3Module.new(Com)
	mq3.init.connect(func(_client: MiniCom.Client, discriminator: int) -> void:
		mq3.set_reporting_delay(0, discriminator)
	)

	mq3.state_changed.connect(func(message: Message, alcohol_detected: bool) -> void:
		debug_print("%s Alcohol detected: %s" % [message.source.get_port(), "YES" if alcohol_detected else "NO"])
	)

	mq3.received_values.connect(func(message: Message, values: MQ3Module.Values) -> void:
		debug_print("%s Alcohol detected: %s, Level: %d" % [message.source.get_port(), "YES" if values.alcohol_detected else "NO", values.value])
	)

	self.keypad = SparkfunKeypadModule.new(Com)
	keypad.key_pressed.connect(func(message: Message, key: String) -> void:
		debug_print("%s Key pressed: %s" % [message.source.get_port(), key])
	)

	self.neoPixel = NeoPixelModule.new(Com)
	neoPixel.init.connect(func(_client: MiniCom.Client, _discriminator: int) -> void:
		print("INIT")
		lastChange = -3
		neoPixel.set_brightness(10)
		neoPixel.set_color(0, Color.DARK_GOLDENROD)
		lastChange = 0
	)
	neoPixel._ready()

	self.bme280 = BME280Module.new(Com)
	bme280.init.connect(func(_client: MiniCom.Client, discriminator: int) -> void:
		bme280.set_reporting_delay(5000, discriminator)
	)

	bme280.received_values.connect(func(message: Message, values: BME280Module.Values) -> void:
		debug_print("%s BME280 values: t=%4.2f h=%4.2f p=%4.2f" % [message.source.get_port(), values.temperature, values.humidity, values.pressure])
	)

	self.mpu6050 = MPU6050Module.new(Com)
	mpu6050.init.connect(func(_client: MiniCom.Client, discriminator: int) -> void:
		mpu6050.set_ranges(MPU6050Module.AccelRange.FS_2, MPU6050Module.GyroRange.FS_2000, discriminator)
		mpu6050.start_calibration(10, discriminator)
	)

	mpu6050.received_values.connect(func(message: Message, values: MPU6050Module.Values) -> void:
		debug_print("%s MPU6050 values: a=(%4.2f, %4.2f, %4.2f), g=(%4.2f, %4.2f, %4.2f)" % [message.source.get_port(), values.acceleration.x, values.acceleration.y, values.acceleration.z, values.gyroscope.x, values.gyroscope.y, values.gyroscope.z])
	)

	mpu6050.received_calibration_values.connect(func(message: Message, values: MPU6050Module.CalibrationValues) -> void:
		debug_print("%s MPU6050 calibration values: a=%s, g=%s" % [message.source.get_port(), values.accel_offset, values.gyro_offset])
	)

	self.pressureSensor = PressureSensorModule.new(Com)
	pressureSensor.init.connect(func(_client: MiniCom.Client, discriminator: int) -> void:
		pressureSensor.set_reporting_delay(500, discriminator)
	)

	pressureSensor.received_value.connect(func(message: Message, value: int) -> void:
		debug_print("%s Pressure value: v=%d" % [message.source.get_port(), value])
	)

	self.potentiometer = PotentiometerModule.new(Com)
	potentiometer.init.connect(func(_client: MiniCom.Client, discriminator: int) -> void:
		potentiometer.set_reporting_delay(500, discriminator)
	)

	potentiometer.received_value.connect(func(message: Message, value: int) -> void:
		debug_print("%s Potentiometer value: v=%d" % [message.source.get_port(), value])
	)

	self.light = LightSensorModule.new(Com)
	light.init.connect(func(_client: MiniCom.Client, discriminator: int) -> void:
		light.set_reporting_delay(500, discriminator)
	)

	light.received_value.connect(func(message: Message, value: int) -> void:
		debug_print("%s Light value: v=%d" % [message.source.get_port(), value])
	)

	self.max4466 = MAX4466Module.new(Com)
	max4466.init.connect(func(_client: MiniCom.Client, discriminator: int) -> void:
		light.set_reporting_delay(500, discriminator)
	)

	max4466.received_value.connect(func(message: Message, value: int) -> void:
		debug_print("%s MAX4466 value: v=%d" % [message.source.get_port(), value])
	)

	self.scd41 = SCD41Module.new(Com)
	scd41.init.connect(func(_client: MiniCom.Client, discriminator: int) -> void:
		scd41.set_reporting_delay(5000, discriminator)
	)

	scd41.received_values.connect(func(message: Message, values: SCD41Module.Values) -> void:
		debug_print("%s SCD41 values: co2=%d t=%4.2f h=%4.2f" % [message.source.get_port(), values.co2, values.temperature, values.humidity])
	)

	scd41._ready()

	self.lis3dh = LIS3DHModule.new(Com)
	lis3dh.init.connect(func(_client: MiniCom.Client, discriminator: int) -> void:
		lis3dh.set_reporting_delay(200, discriminator)
		lis3dh.set_params(LIS3DHModule.DataRate.RATE_1_HZ, LIS3DHModule.PerformanceMode.MODE_LOW_POWER, LIS3DHModule.AccelRange.RANGE_16_G)
	)

	lis3dh.received_values.connect(func(message: Message, values: LIS3DHModule.Values) -> void:
		debug_print("%s LIS3DH values: x=%4.2f y=%4.2f z=%4.2f" % [message.source.get_port(), values.acceleration.x, values.acceleration.y, values.acceleration.z])
	)

	lis3dh._ready()

func _process(delta: float) -> void:
	if lastChange < 0:
		return

	lastChange += delta
	t += delta

	var mult: float = abs(pow(sin(t*4), 10))
	if lastChange > 0.02:
		lastChange = 0

		var colors: Array[Color] = []
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()

		var color: Color = Color.from_rgba8(rng.randi_range(0, 255), rng.randi_range(0, 255), rng.randi_range(0, 255))
		#var color: Color = Color.from_rgba8(mult * 255, mult * 255, 0)
		for i: int in range(0, 30):
			colors.push_back(color)
		for i: int in range(31, 60):
			colors.push_back(Color.from_rgba8(55,55,55))
		neoPixel.set_colors(colors)

func debug_print(s: String) -> void:
	%DebugOutput.text += s + "\n"

func update_modules() -> void:
	for child: Node in %ModuleControls.get_children():
		%ModuleControls.remove_child(child)
		child.queue_free()

	for client: MiniCom.Client in Com.get_clients():
		for module: MiniCom.ClientModule in client.get_capabilities():
			var cb: CheckBox = CheckBox.new()
			cb.text = module.get_id()
			cb.button_pressed = module.is_enabled()
			%ModuleControls.add_child(cb)

			cb.toggled.connect(func(on: bool) -> void:
				Com.set_module_enabled(module.get_id(), on, module.get_discriminator())
			)

func _on_scan_pressed() -> void:
	Com.scan()

func _on_query_capabilities_pressed() -> void:
	Com.query_capabilities()
