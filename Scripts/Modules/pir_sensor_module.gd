class_name PIRSensorModule
extends Module

const ID: String = "pir_sensor"

signal received_presence(message: Message, presence: bool)

var _com: MiniCom
var _presence: Dictionary[int, bool]

func _init(com: MiniCom) -> void:
	self._com = com
	self._com.message_received.connect(_on_message)
	self._presence = {}

func _on_message(m: Message) -> void:
	if m.type == Message.Type.M_PIRSENSOR_PRESENCE:
		var reader: MessageReader = m.reader()
		var presence: bool = reader.get_u8() != 0
		_presence[m.discriminator] = presence
		received_presence.emit(m, presence)

func get_id() -> String:
	return ID

func get_presence(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> bool:
	if discriminator != Message.DEFAULT_DISCRIMINATOR:
		return self._presence.get(Message.DEFAULT_DISCRIMINATOR, false)

	if len(self._presence) == 0:
		return false

	return self._presence.values()[0]
