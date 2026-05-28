class_name MiniCom
extends Node

const DEFAULT_NAME_FILTER = "Arduino"
#const DEFAULT_NAME_FILTER = "Silicon Labs"
const DEFAULT_BAUD_RATE = 115200
const DEFAULT_TIMEOUT = 1000

class ClientModule:
	var _id: String
	var _discriminator: int

	func _init(id: String, discriminator: int):
		self._id = id
		self._discriminator = discriminator

	func _to_string() -> String:
		return "(%s @ %s)" % [_id, _discriminator]

	func get_id() -> String:
		return _id

	func get_discriminator() -> int:
		return _discriminator

class Client:
	var capabilities: Array[ClientModule]

	var _com: MiniCom
	var _port: String
	var _buffer: PackedByteArray
	var _esc: bool

	func _init(com: MiniCom, port: String) -> void:
		self._com = com
		self._port = port

	func _on_data(data: PackedByteArray) -> void:
		print(_port, " > ", data.hex_encode())

		for i in range(data.size()):
			var b: int = data.get(i)
			if !_esc and b == Message.ESC_CHAR:
				_esc = true
				continue

			if !_esc and b == Message.END_CHAR:
				var message: Message = Message.decode(self, _buffer)
				if message == null:
					# Decoding failed
					_buffer.clear()
					continue

				_com.handle_message(self, message)
				_buffer.clear()
				continue

			_buffer.append(b)
			_esc = false

	func get_port() -> String:
		return self._port

	func has_discriminator(discriminator: int):
		for m in capabilities:
			if m.get_discriminator() == discriminator:
				return true
		return false

	func send(message: Message) -> void:
		var data: PackedByteArray = message.pack()
		if data == null:
			return

		_com._manager.write(_port, data)

		print(_port, " < ", data.hex_encode())

signal connected(client: Client)
signal message_received(message: Message)
signal capabilities_received(message: Message, capabilities: Array[ClientModule])
signal debug_print_received(message: Message, text: String)

var name_filter: String = DEFAULT_NAME_FILTER
var baud_rate: int = DEFAULT_BAUD_RATE
var timeout: int = DEFAULT_TIMEOUT

var _manager: GdSerialManager
var _clients: Dictionary[String, Client]

func _init() -> void:
	_manager = GdSerialManager.new()
	_manager.port_disconnected.connect(_on_disconnect)
	_manager.data_received.connect(_on_data)

func _on_disconnect(port: String) -> void:
	_clients.erase(port)

func _on_data(port: String, data: PackedByteArray) -> void:
	var client: Client = _clients.get(port)
	if client == null:
		return
	client._on_data(data)

func _process(_delta: float) -> void:
	_manager.poll_events()

func get_clients() -> Array[Client]:
	var clients: Array[Client] = []
	for port in _clients:
		clients.append(_clients[port])
	return clients

func handle_message(client: Client, message: Message) -> void:
	match message.type:
		Message.Type.M_CAPABILITIES:
			var capabilities: Array[ClientModule] = []
			var reader: MessageReader = message.reader()
			while not reader.is_end():
				var id = reader.get_string()
				var discriminator = reader.get_u8()
				capabilities.append(ClientModule.new(id, discriminator))
			client.capabilities = capabilities
			capabilities_received.emit(message, capabilities)
		Message.Type.M_DEBUG:
			var reader: MessageReader = message.reader()
			var text: String = reader.get_string()
			debug_print_received.emit(message, text)
	message_received.emit(message)

func query_capabilities(client: Client = null) -> void:
	var msg: Message = Message.new(Message.Type.M_CAPABILITIES)
	if client != null:
		client.send(msg)
	else:
		_broadcast_message(msg)

func set_module_enabled(module: String, enabled: bool, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_ENABLE, discriminator)
	builder.put_string(module)
	builder.put_u8(1 if enabled else 0)
	var msg: Message = builder.build()
	send_message(msg)

func _broadcast_message(message: Message) -> void:
	for port in _clients:
		var client: Client = _clients[port]
		client.send(message)

func send_message(message: Message) -> void:
	if message.discriminator != Message.DEFAULT_DISCRIMINATOR:
		for c: Client in _clients.values():
			if c.has_discriminator(message.discriminator):
				c.send(message)
		pass
	else:
		_broadcast_message(message)

func scan() -> void:
	var ports: Dictionary = _manager.list_ports()
	for port_idx: int in ports:
		var port: Dictionary = ports[port_idx]
		var port_name: String = port.port_name
		if _clients.has(port_name):
			continue

		if name_filter not in port.device_name:
			print("Ignoring ", port.device_name)
			continue

		print("Found ", port_name)

		var client: Client = Client.new(self, port_name)
		if not _manager.open(port_name, baud_rate, timeout):
			print("Failed to connect to ", port_name)
			continue

		_clients[port_name] = client
		connected.emit(client)
