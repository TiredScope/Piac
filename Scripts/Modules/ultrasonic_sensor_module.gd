class_name UltrasonicSensorModule
extends Module

const ID: String = "ultrasonic_sensor"

signal received_distance(message: Message, distance: int)

var _distance: Dictionary[int, int]

func _init(com: MiniCom) -> void:
	super(com)
	self._distance = {}

func _on_message(m: Message) -> void:
	if m.type == Message.Type.M_ULTRASONICSENSOR_DISTANCE:
		var reader: MessageReader = m.reader()
		var distance: int = reader.get_u16() != 0
		_distance[m.discriminator] = distance
		received_distance.emit(m, distance)

func get_id() -> String:
	return ID

func get_distance(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> bool:
	if discriminator != Message.DEFAULT_DISCRIMINATOR:
		return self._distance.get(Message.DEFAULT_DISCRIMINATOR, false)

	if len(self._distance) == 0:
		return false

	return self._distance.values()[0]
