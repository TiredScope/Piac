class_name Lobby
extends Node

@onready var notifications: VBoxContainer = %Notifications

var current_piac: PiacInfo

func select_piac(piac: PiacInfo) -> void:
	if current_piac != null:
		# Delete old piac
		pass

	current_piac = piac
	
	if piac != null:
		# TODO: corrent piac body etc.
		add_child(preload("res://scenes/companion.tscn").instantiate())

func _ready() -> void:
	PiacRegistry.register_attribute_generator(PiacTraits.GENERATOR)
	PiacRegistry.register_attribute_generator(PVPPlayerData.GENERATOR)

func _rfid_scanned(uid: PackedByteArray) -> void:
	if len(uid) != 7:
		# TODO: add handling for special control cards
		print("Ignoring scanned uid ", uid)

	var uid_hash: PackedByteArray = AttributeGenerators.generate_hash(uid)
	if current_piac != null and uid_hash == current_piac.uid_hash:
		return
	
	var p: PiacInfo = PiacPlayerManager.get_piac(uid_hash)
	if p == null:
		if current_piac != null:
			# Can't start pvp minigame
			show_notification("Spieler noch nicht erstellt")
			return

		# Hatching minigame
		var hatch: Hatching = preload("res://minigames/hatching/hatching.tscn").instantiate()
		hatch.init_uid(uid)
		get_tree().change_scene_to_node(hatch)
		return

	if current_piac != null:
		# Start PVP minigame
		var pvp: PVP = preload("res://pvp/pvp.tscn").instantiate()
		pvp.init_players(current_piac, p)
		get_tree().change_scene_to_node(pvp)
		return
		
	select_piac(p)

func show_notification(text: String) -> void:
	var noti: Notification = preload("res://scenes/notification.tscn").instantiate()
	noti.text = text
	notifications.add_child(noti)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("simulate_rfid_scan_0", false, true):
		_rfid_scanned(PackedByteArray([0, 0, 0, 0, 0, 0, 0]))
	elif event.is_action_pressed("simulate_rfid_scan_1", false, true):
		_rfid_scanned(PackedByteArray([0, 0, 0, 0, 0, 0, 1]))

func _on_rfid_module_scanned(_message: Message, uid: PackedByteArray) -> void:
	_rfid_scanned(uid)


func _on_interaction_timeout_timeout() -> void:
	select_piac(null)
