class_name Hatching
extends Control

var uid: PackedByteArray

func init_uid(p_uid: PackedByteArray) -> void:
	uid = p_uid

func _on_timer_timeout() -> void:
	var p: PiacInfo = PiacPlayerManager.create_new_piac(uid, "Hello World!")
	print("Made new player: ", p)
	
	var main: Lobby = (load("res://scenes/main.tscn") as PackedScene).instantiate()
	get_tree().change_scene_to_node(main)
	main.select_piac(p)
