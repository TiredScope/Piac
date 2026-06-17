class_name MiniCom
extends Node

const DEFAULT_NAME_FILTER: Array[String] = [
	"Arduino",
	"Silicon Labs",
	"Adafruit",
]

#const DEFAULT_NAME_FILTER = "Silicon Labs"
const DEFAULT_BAUD_RATE = 9600
const DEFAULT_TIMEOUT = 100

class ClientModule:
	var _id: String
	var _discriminator: int
	var _enabled: bool

	func _init(id: String, discriminator: int, enabled: bool) -> void:
		self._id = id
		self._discriminator = discriminator
		self._enabled = enabled

	func _to_string() -> String:
		return "(%s @ %s: [%s])" % [_id, _discriminator, "ON" if _enabled else "OFF"]

	func get_id() -> String:
		return _id

	func get_discriminator() -> int:
		return _discriminator

	func is_enabed() -> bool:
		return _enabled

class Client:
	var _com: MiniCom
	var _port: String
	var _buffer: PackedByteArray
	var _esc: bool

	var _capabilities: Array[ClientModule] = []
	var _ready: bool = false

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
		return _port

	func is_ready() -> bool:
		return _ready

	func get_capabilities(id: String = "") -> Array[ClientModule]:
		var caps: Array[ClientModule]
		for m in _capabilities:
			if id != "" and m.get_id() != id:
				continue
			caps.push_back(m)

		return caps

	func has_capability(id: String) -> bool:
		return not get_capabilities(id).is_empty()

	func has_discriminator(discriminator: int) -> bool:
		for m in _capabilities:
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
signal is_ready(client: Client)
signal disconnected(client: Client)
signal message_received(message: Message)
signal capabilities_received(message: Message, capabilities: Array[ClientModule])
signal debug_print_received(message: Message, text: String)

var name_filter: Array[String] = DEFAULT_NAME_FILTER
var baud_rate: int = DEFAULT_BAUD_RATE
var timeout: int = DEFAULT_TIMEOUT

var _manager: GdSerialManager
var _clients: Dictionary[String, Client]

func _init() -> void:
	_manager = GdSerialManager.new()
	_manager.port_disconnected.connect(_on_disconnect)
	_manager.data_received.connect(_on_data)

func _on_disconnect(port: String) -> void:
	var client: Client = _clients.get(port)
	if client == null:
		return

	disconnected.emit(client)
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
				var id: String = reader.get_string()
				var discriminator: int = reader.get_u8()
				var enabled: bool = reader.get_u8() != 0
				capabilities.append(ClientModule.new(id, discriminator, enabled))
			client._capabilities = capabilities
			capabilities_received.emit(message, capabilities)

			if not client._ready:
				client._ready = true
				is_ready.emit(client)
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

	for c: Client in get_clients_by_discriminator(discriminator):
		for m: ClientModule in c.get_capabilities():
			if m.get_id() == module:
				m._enabled = enabled

func _broadcast_message(message: Message) -> void:
	for port in _clients:
		var client: Client = _clients[port]
		client.send(message)

func get_clients_by_discriminator(discriminator: int) -> Array[Client]:
	if discriminator != Message.DEFAULT_DISCRIMINATOR:
		return _clients.values().filter(func(c: Client) -> void:
			return c.has_discriminator(discriminator)
		)
	else:
		return _clients.values()

func send_message(message: Message) -> void:
	for c: Client in get_clients_by_discriminator(message.discriminator):
		c.send(message)

func scan() -> void:
	var ports: Dictionary = _manager.list_ports()
	for port_idx: int in ports:
		var port: Dictionary = ports[port_idx]
		var port_name: String = port.port_name
		if _clients.has(port_name):
			continue

		var found: bool = false
		for filter in name_filter:
			if filter in port.device_name:
				found = true
				break

		if not found:
			print("Ignoring ", port.device_name)
			continue

		print("Found ", port_name)

		var client: Client = Client.new(self, port_name)
		if not _manager.open(port_name, baud_rate, timeout):
			print("Failed to connect to ", port_name)
			continue

		_clients[port_name] = client
		connected.emit(client)
