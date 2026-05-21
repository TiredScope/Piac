extends Node

var rfid: RFIDModule

func _init() -> void:
	Com.connected.connect(func(client: MiniCom.Client):
		debug_print("%s connected" % [client.get_port()])
	)

	Com.message_received.connect(func(message: Message):
		if message.type in [Message.Type.M_NOP, Message.Type.M_DEBUG, Message.Type.M_CAPABILITIES]:
			return

		debug_print("%s > %s" % [message.source.get_port(), message.to_string()])
	)

	Com.capabilities_received.connect(func(message: Message, capabilities: Array[MiniCom.ClientModule]):
		debug_print("%s has capabilities %s" % [message.source.get_port(), capabilities])
	)

	Com.debug_print_received.connect(func(message: Message, text: String):
		debug_print("%s > [DEBUG] %s" % [message.source.get_port(), text])
	)

	self.rfid = RFIDModule.new(Com)
	rfid.scanned.connect(func(message: Message, uid: PackedByteArray):
		debug_print("%s scanned tag with uid %s" % [message.source.get_port(), uid.hex_encode()])
		debug_print("Generated traits: %s" % [TraitGenerator.generate_traits(uid)])
	)

func _on_button_pressed() -> void:
	Com.scan()
	pass

func debug_print(s: String):
	%DebugOutput.text += s + "\n"


func _on_check_box_toggled(toggled_on: bool) -> void:
	Com.set_module_enabled(RFIDModule.ID, toggled_on, 0)
