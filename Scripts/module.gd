@abstract class_name Module

signal init(client: MiniCom.Client, discriminator: int)

var _com: MiniCom

func _init(com: MiniCom) -> void:
	_com = com

	_com.is_ready.connect(_init_client)
	_com.message_received.connect(_on_message)

	for c: MiniCom.Client in _com.get_clients():
		_init_client(c)

func _init_client(client: MiniCom.Client) -> void:
	var cap: Array[MiniCom.ClientModule] = client.get_capabilities(get_id())
	for m in cap:
		init.emit(client, m.get_discriminator())

@abstract func _on_message(m: Message) -> void
@abstract func get_id() -> String

func is_available() -> bool:
	for client in Com.get_clients():
		if client.has_capability(get_id()):
			return true
	return false
