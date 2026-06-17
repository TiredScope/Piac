class_name NeoPixelModule
extends Module

const ID: String = "neopixel"

func _on_message(_m: Message) -> void:
	pass

func get_id() -> String:
	return ID

func set_brightness(brightness: int, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_NEOPIXEL_SET_BRIGHTNESS, discriminator)

	builder.put_u8(brightness)

	_com.send_message(builder.build())

func set_colors(colors: Array[Color], offset: int = 0, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_NEOPIXEL_SET_COLORS, discriminator)

	builder.put_u16(offset)
	for color in colors:
		builder.put_u8(color.r8)
		builder.put_u8(color.g8)
		builder.put_u8(color.b8)
		builder.put_u8(color.a8)

	_com.send_message(builder.build())

func set_color(index: int, color: Color, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	set_colors([color], index, discriminator)
