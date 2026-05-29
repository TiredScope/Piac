extends Node

var rfid: RFIDModule
var pulse_sensor: PulseSensorModule

func _init() -> void:
	Com.connected.connect(func(client: MiniCom.Client):
		debug_print("%s connected" % [client.get_port()])
	)

	Com.disconnected.connect(func(client: MiniCom.Client):
		debug_print("%s disconnected" % [client.get_port()])
		update_modules()
	)

	Com.message_received.connect(func(message: Message):
		if message.type in [Message.Type.M_NOP, Message.Type.M_DEBUG]:
			return

		debug_print("%s > %s" % [message.source.get_port(), message.to_string()])
	)

	Com.capabilities_received.connect(func(message: Message, capabilities: Array[MiniCom.ClientModule]):
		debug_print("%s has capabilities %s" % [message.source.get_port(), capabilities])
		update_modules()
	)

	Com.debug_print_received.connect(func(message: Message, text: String):
		debug_print("%s > [DEBUG] %s" % [message.source.get_port(), text])
	)

	self.rfid = RFIDModule.new(Com)
	rfid.scanned.connect(func(message: Message, uid: PackedByteArray):
		debug_print("%s scanned tag with uid %s" % [message.source.get_port(), uid.hex_encode()])
		debug_print("Generated traits: %s" % [TraitGenerator.generate_traits(uid)])
	)

	self.pulse_sensor = PulseSensorModule.new(Com)
	pulse_sensor.heartbeat.connect(func(message: Message, bpm: int):
		debug_print("%s BPM: %s" % [message.source.get_port(), bpm])
	)

func debug_print(s: String):
	%DebugOutput.text += s + "\n"

func update_modules():
	for child: Node in %ModuleControls.get_children():
		%ModuleControls.remove_child(child)
		child.queue_free()

	for client in Com.get_clients():
		for module: MiniCom.ClientModule in client.capabilities:
			var cb: CheckBox = CheckBox.new()
			cb.text = module.get_id()
			cb.button_pressed = module.is_enabed()
			%ModuleControls.add_child(cb)

			cb.toggled.connect(func(on: bool):
				Com.set_module_enabled(module.get_id(), on, module.get_discriminator())
			)

func _on_scan_pressed() -> void:
	Com.scan()

func _on_query_capabilities_pressed() -> void:
	Com.query_capabilities()
