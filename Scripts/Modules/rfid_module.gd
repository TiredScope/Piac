class_name RFIDModule
extends Module

const ID: String = "rfid"

signal scan_failed(message: Message)
signal scanned(message: Message, uid: PackedByteArray)

func _init(com: MiniCom) -> void:
	super(com)

func _on_message(m: Message) -> void:
	match m.type:
		Message.Type.M_RFID_SCAN_FAILED:
			scan_failed.emit(m)
		Message.Type.M_RFID_SCANNED:
			var reader: MessageReader = m.reader()
			var uid_size: int = reader.get_u8()
			var uid: PackedByteArray = reader.get_bytes(uid_size)
			scanned.emit(m, uid)

func get_id() -> String:
	return ID
