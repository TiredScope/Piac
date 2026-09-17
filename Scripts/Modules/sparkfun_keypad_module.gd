class_name SparkfunKeypadModule
extends Module

const ID: String = "sparkfun_keypad"

signal key_pressed(message: Message, key: String)

func _init(com: MiniCom = Com) -> void:
	super(com)

func _on_message(m: Message) -> void:
	match m.type:
		Message.Type.M_SPARKFUN_KEYPAD_KEY:
			var reader: MessageReader = m.reader()
			var key: String = String.chr(reader.get_u8())
			key_pressed.emit(m, key)

func get_id() -> String:
	return ID
