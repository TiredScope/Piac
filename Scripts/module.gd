@abstract class_name Module

@abstract func get_id() -> String

func is_available() -> bool:
	for client in Com.get_clients():
		if client.capabilities.has(get_id()):
			return true
	return false
