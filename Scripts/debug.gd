extends Node

var reference_node: Node = Node.new()
@onready var bme280: BME280Module = %Modules.get_node("BME280Module")
@onready var bmp280: BMP280Module = %Modules/BMP280Module
@onready var circuit_playground: CircuitPlaygroundModule = %Modules/CircuitPlaygroundModule
@onready var df_player: DFPlayerModule = %Modules/DFPlayerModule
@onready var dht22: DHT22Module = %Modules/DHT22Module
@onready var ds3231: DS3231Module = %Modules/DS3231Module
@onready var ir_receiver: IRReceiverModule = %Modules/IRReceiverModule
@onready var joystick: JoystickModule = %Modules/JoystickModule
@onready var lcd: LCDModule = %Modules/LCDModule
@onready var led_matrix: LEDMatrixModule = %Modules/LEDMatrixModule
@onready var lis3dh: LIS3DHModule = %Modules/LIS3DHModule
@onready var light_sensor: LightSensorModule = %Modules/LightSensorModule
@onready var max4466: MAX4466Module = %Modules/MAX4466Module
@onready var mpu6050: MPU6050Module = %Modules/MPU6050Module
@onready var mq3: MQ3Module = %Modules/MQ3Module
@onready var neo_pixel: NeoPixelModule = %Modules/NeoPixelModule
@onready var nunchuk: NunchukModule = %Modules/NunchukModule
@onready var pir: PIRSensorModule = %Modules/PIRSensorModule
@onready var potentiometer: PotentiometerModule = %Modules/PotentiometerModule
@onready var pressure_sensor: PressureSensorModule = %Modules/PressureSensorModule
@onready var pulse_sensor: PulseSensorModule = %Modules/PulseSensorModule
@onready var rfid: RFIDModule = %Modules/RFIDModule
@onready var scd41: SCD41Module = %Modules/SCD41Module
@onready var sparkfun_keypad: SparkfunKeypadModule = %Modules/SparkfunKeypadModule

var t: float = 0
var lastChange: float = -1

func _ready() -> void:
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

	for m: Module in %Modules.get_children():
		_connect_signals_to_log(m)
		m.init.connect(func(client: MiniCom.Client, discriminator: int) -> void:
			debug_print("%s initialized with discriminator %d" % [client.get_port(), discriminator]
		))

	return

class CallInfo:
	var module: String
	var signal_name: String
	var arg_names: Array[String] = []
	var message_arg: int

func _log_signal_invocation(a: Variant, b: Variant, c: Variant, d: Variant, e: Variant, f: Variant, g: Variant, h: Variant, call_info: CallInfo) -> void:
	var args: Array[Variant] = [a, b, c, d, e, f, g, h]

	var message: Message = null
	if call_info.message_arg != -1:
		message = args[call_info.message_arg] as Message

	var label: String = call_info.module
	if message != null:
		label += " @ " + str(message.discriminator)

	var log_parts: Array[String] = []
	for i: int in range(len(call_info.arg_names)):
		if i == call_info.message_arg:
			continue

		var arg: Variant = args[i]
		print(call_info.arg_names)
		log_parts.push_back("%s=%s" % [call_info.arg_names[i], arg])

	debug_print("[" + label + "] " + call_info.signal_name + ": " + ", ".join(log_parts))

func _connect_signals_to_log(module: Module) -> void:
	var base_signals: Array[Dictionary] = reference_node.get_signal_list()

	for sig: Dictionary in module.get_signal_list():
		if base_signals.any(func(s: Dictionary) -> bool:
			return sig.name == s.name
		):
			continue

		var call_info: CallInfo = CallInfo.new()
		call_info.module = module.get_id()
		call_info.signal_name = sig.name
		call_info.message_arg = -1

		for i: int in range(len(sig.args)):
			var arg: Dictionary = sig.args[i]
			if arg.class_name == "Message":
				call_info.message_arg = i

			call_info.arg_names.push_back(arg.name)

		var callable: Callable = Callable.create(self, "_log_signal_invocation").bind(call_info)
		for _i: int in range(callable.get_argument_count() - len(sig.args)):
			callable = callable.bind(null)

		module.connect(StringName(sig.name as String), callable)

func _process(delta: float) -> void:
	if lastChange < 0:
		return

	lastChange += delta
	t += delta

	#var mult: float = abs(pow(sin(t*4), 10))
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
		neo_pixel.set_colors(colors)

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
