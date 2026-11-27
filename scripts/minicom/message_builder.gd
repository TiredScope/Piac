class_name MessageBuilder

var _type: Message.Type
var _discriminator: int
var _buffer: StreamPeerBuffer

func _init(type: Message.Type, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	self._type = type
	self._discriminator = discriminator
	self._buffer = StreamPeerBuffer.new()
	self._buffer.big_endian = true

func put_i8(value: int) -> void:
	_buffer.put_8(value)

func put_u8(value: int) -> void:
	_buffer.put_u8(value)

func put_i16(value: int) -> void:
	_buffer.put_16(value)

func put_u16(value: int) -> void:
	_buffer.put_u16(value)

func put_i32(value: int) -> void:
	_buffer.put_32(value)

func put_u32(value: int) -> void:
	_buffer.put_u32(value)

func put_f32(value: float) -> void:
	_buffer.put_float(value)

func put_string(value: String) -> void:
	_buffer.put_data(value.to_ascii_buffer())
	_buffer.put_u8(0)

func put_bytes(value: PackedByteArray) -> void:
	_buffer.put_data(value)

func build() -> Message:
	return Message.new(_type, _discriminator, _buffer.data_array)
