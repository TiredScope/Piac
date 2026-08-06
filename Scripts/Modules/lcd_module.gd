class_name LCDModule
extends Module

const ID: String = "lcd"

enum {
	LCD_CURSOR = 0x01,
	LCD_BLINK = 0x02,
	LCD_AUTOSCROLL = 0x04,
	LCD_DISPLAY = 0x08,
	LCD_RIGHT_TO_LEFT = 0x10, # 1 == scroll left, 0 == scroll right
}

var _com: MiniCom

func _init(com: MiniCom) -> void:
	self._com = com

func get_id() -> String:
	return ID

func set_settings(settings: int, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_LCD_SETTINGS, discriminator)
	builder.put_u32(settings)
	_com.send_message(builder.build())

func clear(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	_com.send_message(Message.new(Message.Type.M_LCD_CLEAR, discriminator))

func print(text: String, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_LCD_PRINT, discriminator)
	builder.put_string(text)
	_com.send_message(builder.build())
