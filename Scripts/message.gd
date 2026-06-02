class_name Message

const ESC_CHAR = 0x1B
const END_CHAR = 0x0A # == '\n'
const MAX_MESSAGE_LENGTH = 255
const DEFAULT_DISCRIMINATOR = 0

enum Type {
	M_NOP = 0x0000,
	M_PING = 0x0001,
	M_CAPABILITIES = 0x0002,
	M_ENABLE = 0x0003,
	M_DEBUG = 0x0004,

	# LCDModule
	M_LCD_SETTINGS = 0x0100,
	M_LCD_CLEAR = 0x0101,
	M_LCD_PRINT = 0x0102,

	# JoystickModule
	M_JOYSTICK_VALUES = 0x0200,

	# LEDMatrixModule
	M_LEDMATRIX_IMAGE = 0x0300,

	# NunchukModule
	M_NUNCHUK_VALUES = 0x0400,

	# RFIDModule
	M_RFID_SCANNED = 0x0500,
	M_RFID_SCAN_FAILED = 0x0501,

	# PulseSensorModule
	M_PULSESENSOR_HEARTBEAT = 0x0600,

	# PIRSensorModule
	M_PIRSENSOR_PRESENCE = 0x0700,

	# UltrasonicSensorModule
	M_ULTRASONICSENSOR_DISTANCE = 0x0800,
}

var type: Type
var discriminator: int
var body: PackedByteArray
var source: MiniCom.Client
var _idx: int

func _init(m_type: Type, m_discriminator: int = DEFAULT_DISCRIMINATOR, m_body: PackedByteArray = PackedByteArray(), m_source: MiniCom.Client = null) -> void:
	self.type = m_type
	self.discriminator = m_discriminator
	self.body = m_body
	self.source = m_source
	self._idx = 0

func _to_string() -> String:
	return "MSG [ source={source}, message_type={message_type}, discriminator={discriminator}, body={body} ]".format({
		"source": source.get_port() if source != null else "null",
		"discriminator": discriminator,
		"message_type": "<INVALID>" if not type in Type.values() else Type.keys()[Type.values().find(type)],
		"body": body.hex_encode(),
	})

func pack() -> PackedByteArray:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = true
	stream.resize(2 + 1 + 1 + body.size())
	stream.put_u16(type)
	stream.put_u8(discriminator)
	var checksum: int = 0
	for b in body:
		checksum ^= b
	stream.put_partial_data(body)
	stream.put_u8(checksum)

	# Kind of a cheap hack, performance might not be great
	var raw_bytes: PackedByteArray = stream.data_array
	var escaped_bytes: PackedByteArray = PackedByteArray()
	for b in raw_bytes:
		if b == ESC_CHAR or b == END_CHAR:
			escaped_bytes.append(Message.ESC_CHAR)
		escaped_bytes.append(b)
	escaped_bytes.append(END_CHAR)

	if escaped_bytes.size() > MAX_MESSAGE_LENGTH:
		print("Cannot pack message, too large")
		return PackedByteArray()

	return escaped_bytes

func reader() -> MessageReader:
	return MessageReader.new(self)

static func decode(m_source: MiniCom.Client, data: PackedByteArray) -> Message:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = true
	stream.data_array = data
	var m_type: Type = stream.get_u16() as Type
	var m_discriminator: int = stream.get_u8()
	var bd: PackedByteArray = stream.get_data(max(stream.get_available_bytes() - 1, 0))[1]
	var checksum: int = stream.get_u8()

	var calculated_checksum: int = 0
	for b in bd:
		calculated_checksum ^= b

	if calculated_checksum != checksum:
		print("Checksum validation failed for message")
		return null

	return Message.new(m_type, m_discriminator, bd, m_source)
