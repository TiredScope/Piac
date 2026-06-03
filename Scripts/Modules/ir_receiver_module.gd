class_name IRReceiverModule
extends Module

const ID: String = "ir_receiver"

class IRData:
	var protocol: int
	var flags: int
	var address: int
	var command: int
	var extra: int

signal data_received(message: Message, bpm: int)

var _com: MiniCom

func _init(com: MiniCom) -> void:
	self._com = com
	self._com.message_received.connect(_on_message)

func _on_message(m: Message) -> void:
	match m.type:
		Message.Type.M_IRRECEIVER_DATA:
			var reader: MessageReader = m.reader()

			var data: IRData = IRData.new()
			data.protocol = reader.get_u16()
			data.flags = reader.get_u8()
			data.address = reader.get_u16()
			data.command = reader.get_u16()
			data.extra = reader.get_u16()
			data_received.emit(m, data)

func get_id() -> String:
	return ID
