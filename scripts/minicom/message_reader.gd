class_name MessageReader
extends Node

var _buffer: StreamPeerBuffer

func _init(m: Message) -> void:
	self._buffer = StreamPeerBuffer.new()
	self._buffer.big_endian = true
	self._buffer.data_array = m.body

func get_i8() -> int:
	return _buffer.get_8()

func get_u8() -> int:
	return _buffer.get_u8()

func get_i32() -> int:
	return _buffer.get_32()

func get_u32() -> int:
	return _buffer.get_u32()

func get_i16() -> int:
	return _buffer.get_16()

func get_u16() -> int:
	return _buffer.get_u16()

func get_f32() -> float:
	return _buffer.get_float()

func get_string() -> String:
	var buf: PackedByteArray
	while true:
		if _buffer.get_available_bytes() == 0:
			break

		var byte: int = _buffer.get_u8()
		if byte == 0:
			break

		buf.push_back(byte)
	return buf.get_string_from_ascii()

func get_bytes(length: int) -> PackedByteArray:
	return _buffer.get_data(length)[1]

func is_end() -> bool:
	return _buffer.get_available_bytes() == 0
