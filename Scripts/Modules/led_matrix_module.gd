class_name LEDMatrixModule
extends Module

const ID: String = "led_matrix"

var _com: MiniCom

func _init(com: MiniCom) -> void:
	self._com = com

func get_id() -> String:
	return ID

func send_image(image: PackedByteArray, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	if image.size() != 8:
		return

	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_LEDMATRIX_IMAGE, discriminator)
	for b in image:
		builder.put_u8(b)

	_com.send_message(builder.build())
