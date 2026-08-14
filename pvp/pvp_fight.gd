class_name PVPFight
extends Control

class PVPPlayer:
	var items: Array[ItemData]
	var values: AttackValues

var player1: PVPPlayer
var player2: PVPPlayer

@onready var _light_sensor: LightSensorModule = $Modules/LightSensorModule
@onready var _pressure_sensor: PressureSensorModule = $Modules/PressureSensorModule
@onready var _potentiometer: PotentiometerModule = $Modules/PotentiometerModule

@onready var _normal: ProgressBar = $VBoxContainer/Normal
@onready var _crit: ProgressBar = $VBoxContainer/Crit
@onready var _block: ProgressBar = $VBoxContainer/Block

func _ready() -> void:
	_show_values(player1)

func _process(_delta: float) -> void:
	var change: float = -0.1 if Input.is_key_pressed(KEY_SHIFT) else 0.1
	if Input.is_action_just_pressed("ui_left"):
		player1.values.normal += change
		_show_values(player1)

	if Input.is_action_just_pressed("ui_up"):
			player1.values.crit += change
			_show_values(player1)

	if Input.is_action_just_pressed("ui_right"):
			player1.values.block += change
			_show_values(player1)


func _show_values(player: PVPPlayer) -> void:
	#_normal.value = values.normal
	#_crit.value = values.crit
	#_block.value = values.block
	pass

func _on_light_sensor_module_init(_client: MiniCom.Client, discriminator: int) -> void:
	_light_sensor.set_reporting_delay(100, discriminator)

func _on_light_sensor_module_received_value(message: Message, value: int) -> void:
	print("Light sensor (%d): %d" % [message.discriminator, value])


func _on_potentiometer_module_init(_client: MiniCom.Client, discriminator: int) -> void:
	_potentiometer.set_reporting_delay(100, discriminator)

func _on_potentiometer_module_received_value(message: Message, value: int) -> void:
	print("Potentiometer (%d): %d" % [message.discriminator, value])


func _on_pressure_sensor_module_init(_client: MiniCom.Client, discriminator: int) -> void:
	_pressure_sensor.set_reporting_delay(100, discriminator)

func _on_pressure_sensor_module_received_value(message: Message, value: int) -> void:
	print("Pressure sensor (%d): %d" % [message.discriminator, value])

class AttackValues:
	var _normal: float = 1.0/3.0
	var _crit: float = 1.0/3.0
	var _block: float = 1.0/3.0

	var normal: float:
		get():
			return _normal
		set(value):
			update_value("_normal", value)

	var crit: float:
		get():
			return _crit
		set(value):
			update_value("_crit", value)

	var block: float:
		get():
			return _block
		set(value):
			update_value("_block", value)

	func update_value(prop: StringName, new_value: float) -> void:
		# TODO: If this feels bad in testing, just remove the value adjustment of the other values
		# and instead just normalize everything to a total of 1
		var max_value: float = 0.7 # TODO: obedience
		new_value = clampf(new_value, 0, max_value)

		var old_value: float = get(prop)

		var delta: float = new_value - old_value
		var remaining_delta: float = delta
		var all_props: Array[StringName] = ["_normal", "_crit", "_block"]
		for o: StringName in all_props:
			if o == prop:
				continue

			var val: float = get(o)
			var to_deduct: float = clampf(delta / (len(all_props) - 1), val - 1, val)
			print("Deducting ", to_deduct)
			set(o, val - to_deduct)
			remaining_delta -= to_deduct

		set(prop, new_value - remaining_delta)
		print(remaining_delta)
		print("N ", normal, " | C ", crit, " | B ", block)
