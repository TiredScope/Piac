extends Node

func _ready() -> void:
	PiacRegistry.register_trait_generator("default", TraitGenerator._generate_default_traits, ContentRegistry.RandomType.CONSISTENT)

func _rfid_scanned(uid: PackedByteArray) -> void:
	if len(uid) != 7:
		print("Ignoring scanned uid ", uid)

	var uid_hash: PackedByteArray = TraitGenerator.generate_hash(uid)
	var p: PiacInfo = PiacPlayerManager.get_piac(uid_hash)
	if p == null:
		p = PiacPlayerManager.create_new_piac(uid, "Hello World!")
		print("Made new player: ", p)

	TraitGenerator.generate_traits(p)

	add_child(preload("res://scenes/companion.tscn").instantiate())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("simulate_rfid_scan_0", false, true):
		_rfid_scanned(PackedByteArray([0, 0, 0, 0, 0, 0, 0]))
	elif event.is_action_pressed("simulate_rfid_scan_1", false, true):
		_rfid_scanned(PackedByteArray([0, 0, 0, 0, 0, 0, 1]))

func _on_rfid_module_scanned(_message: Message, uid: PackedByteArray) -> void:
	_rfid_scanned(uid)
