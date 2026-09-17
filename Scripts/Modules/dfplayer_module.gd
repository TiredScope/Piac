class_name DFPlayerModule
extends Module

const ID: String = "dfplayer"

const DEFAULT_VOLUME: int = 10

class State:
	var paused: bool = false
	var looping: bool = false

	var state: int = 0
	var volume: int = DEFAULT_VOLUME
	var eq: int = 0
	var current_file: int = 0
	var file_count: int = 0
	var folder_file_counts: Array[int]

	static func copy(src: State) -> State:
		var copy_value: State = State.new()
		copy_value.paused = src.paused
		copy_value.looping = src.looping

		copy_value.state = src.state
		copy_value.volume = src.volume
		copy_value.eq = src.eq
		copy_value.current_file = src.current_file
		copy_value.file_count = src.file_count
		copy_value.folder_file_counts = src.folder_file_counts.duplicate()
		return copy_value

enum Event {
	CARD_INSERTED = 0x01,
	CARD_REMOVED = 0x02,
	CARD_ONLINE = 0x03,
	USB_INSERTED = 0x04,
	USB_REMOVED = 0x05,
	PLAY_FINISHED = 0x06,

	ERROR_TIMEOUT = 0x80,
	ERROR_NO_CARD = 0x81,
	ERROR_FILE_NOT_FOUND = 0x82,  # OOB or not found
	ERROR_OTHER = 0x83,
}

signal received_state(message: Message, values: State)
signal received_event(message: Message, event: Event)

var _states: Dictionary[int, State]

func _init(com: MiniCom) -> void:
	super(com)
	self._states = {}

func _on_message(m: Message) -> void:
	match m.type:
		Message.Type.M_DFPLAYER_STATE:
			var reader: MessageReader = m.reader()

			var state: State = State.copy(get_state(m.discriminator))
			state.state = reader.get_u16()
			state.volume = reader.get_u8()
			state.eq = reader.get_u8()
			state.current_file = reader.get_u16()
			state.file_count = reader.get_u16()

			var folder_count: int = reader.get_u8()
			var folder_counts: Array[int] = []
			folder_counts.resize(folder_count)
			for i: int in range(folder_count):
				folder_counts.append(reader.get_u16())

			state.folder_file_counts = folder_counts

			_states[m.discriminator] = state
			received_state.emit(m, state)
		Message.Type.M_DFPLAYER_EVENT:
			var reader: MessageReader = m.reader()

			var event: Event = reader.get_u8() as Event
			received_event.emit(m, event)

func get_id() -> String:
	return ID

func play(file: int, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_DFPLAYER_PLAY, discriminator)
	builder.put_u16(file)
	_com.send_message(builder.build())

func play_folder(folder: int, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_DFPLAYER_PLAY_FOLDER, discriminator)
	builder.put_u8(folder)
	_com.send_message(builder.build())

func next(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	_com.send_message(Message.new(Message.Type.M_DFPLAYER_NEXT, discriminator))

func previous(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	_com.send_message(Message.new(Message.Type.M_DFPLAYER_PREVIOUS, discriminator))

func set_volume(volume: int, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_DFPLAYER_VOLUME, discriminator)
	builder.put_u8(volume)
	_com.send_message(builder.build())

func set_loop(loop: bool, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_DFPLAYER_LOOP, discriminator)
	builder.put_u8(1 if loop else 0)
	_com.send_message(builder.build())

func loop_one(file: int, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_DFPLAYER_LOOP_ONE, discriminator)
	builder.put_u16(file)
	_com.send_message(builder.build())

func loop_folder(folder: int, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_DFPLAYER_LOOP_FOLDER, discriminator)
	builder.put_u8(folder)
	_com.send_message(builder.build())

func loop_all(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	_com.send_message(Message.new(Message.Type.M_DFPLAYER_LOOP_ALL, discriminator))

func pause(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	_com.send_message(Message.new(Message.Type.M_DFPLAYER_PAUSE, discriminator))

func start(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	_com.send_message(Message.new(Message.Type.M_DFPLAYER_START, discriminator))

func random_all(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	_com.send_message(Message.new(Message.Type.M_DFPLAYER_RANDOM_ALL, discriminator))

# TODO: eq constants
func set_eq(eq: int, discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	var builder: MessageBuilder = MessageBuilder.new(Message.Type.M_DFPLAYER_EQ, discriminator)
	builder.put_u8(eq)
	_com.send_message(builder.build())

func query_state(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> void:
	_com.send_message(Message.new(Message.Type.M_DFPLAYER_QUERY_STATE, discriminator))

func get_state(discriminator: int = Message.DEFAULT_DISCRIMINATOR) -> State:
	if discriminator != Message.DEFAULT_DISCRIMINATOR:
		return _states.get(Message.DEFAULT_DISCRIMINATOR, State.new())

	if len(_states) == 0:
		return State.new()

	return _states.values()[0]
