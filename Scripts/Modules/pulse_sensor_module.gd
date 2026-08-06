class_name PulseSensorModule
extends Module

const ID: String = "pulse_sensor"

signal heartbeat(message: Message, bpm: int)

func _on_message(m: Message) -> void:
	match m.type:
		Message.Type.M_PULSESENSOR_HEARTBEAT:
			var reader: MessageReader = m.reader()
			var bpm: int = reader.get_u8()
			heartbeat.emit(m, bpm)

func get_id() -> String:
	return ID
