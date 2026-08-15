class_name PVPFight
extends Control

class PVPPlayer:
	var values: PVPValues
	var hp: int
	var items: Array[ItemData] = []
	var attack_values: AttackValues = AttackValues.new()

	func _init(p_values: PVPValues, p_items: Array[ItemData]) -> void:
		values = p_values
		items = p_items

		for item: ItemData in items:
			values = PVPValues.add(values, item.bonus)

		hp = int(values.get_value(Stats.PVPStat.HP))

@onready var _player1_stats: PVPPlayerStats = %Player1Stats
@onready var _player2_stats: PVPPlayerStats = %Player2Stats

@onready var _light_sensor: LightSensorModule = $Modules/LightSensorModule
@onready var _pressure_sensor: PressureSensorModule = $Modules/PressureSensorModule
@onready var _potentiometer: PotentiometerModule = $Modules/PotentiometerModule

@onready var _countdown: Label = %Countdown
@onready var _countdown_player: AnimationPlayer = %Countdown/AnimationPlayer

@onready var _first_round_timer: Timer = $Timers/FirstRound
@onready var _attack_timer: Timer = $Timers/Attack
@onready var _between_rounds_timer: Timer = $Timers/BetweenRounds
@onready var _countdown_timer: Timer = $Timers/Countdown

@onready var _round_status: Label = %RoundStatus

var player1: PVPPlayer
var player2: PVPPlayer

var _current_round: int = 0
var _current_countdown: int = 0

func _ready() -> void:
	_show_values()

	await get_tree().create_timer(1.0).timeout
	_start_countdown(int(_first_round_timer.wait_time))
	_first_round_timer.start()

func init_players(player1_values: PVPValues, player1_items: Array[ItemData], player2_values: PVPValues, player2_items: Array[ItemData]) -> void:
	player1 = PVPPlayer.new(player1_values, player1_items)
	player2 = PVPPlayer.new(player2_values, player2_items)
	pass

func _process(_delta: float) -> void:
	var change: float = -0.1 if Input.is_key_pressed(KEY_SHIFT) else 0.1
	var attack_values: AttackValues = player2.attack_values if Input.is_key_pressed(KEY_CTRL) else player1.attack_values

	if Input.is_action_just_pressed("simulate_sensor_1"):
		attack_values.normal += change
		_show_values()

	if Input.is_action_just_pressed("simulate_sensor_2"):
		attack_values.crit += change
		_show_values()

	if Input.is_action_just_pressed("simulate_sensor_3"):
		attack_values.block += change
		_show_values()

func _show_values() -> void:
	_player1_stats.show_values(player1)
	_player2_stats.show_values(player2)

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

func _start_round() -> void:
	_current_round += 1
	_round_status.text = "Runde %d" % [_current_round]
	_attack_timer.start()
	_start_countdown(int(_attack_timer.wait_time))

func _start_countdown(time: int) -> void:
	_current_countdown = time
	_countdown_timer.start()
	_show_countdown()

func _show_countdown() -> void:
	if _current_countdown <= 0:
		_countdown.visible = false
		_countdown_timer.stop()
		return

	_countdown.text = str(_current_countdown)
	_countdown.visible = true
	_current_countdown -= 1
	_countdown_player.play("pop")


func _on_attack_timeout() -> void:
	_calculate_attacks()
	_round_status.text = "Runde %d vorbei" % [_current_round]
	_between_rounds_timer.start()

func _calculate_attacks() -> void:
	player1.hp -= 5
	# TODO: calculate actual values
	# TODO: play some fancy animations
	_show_values()
	pass


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	_countdown.visible = false
