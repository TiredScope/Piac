class_name Notification
extends Label

func _on_timer_timeout() -> void:
	queue_free()
