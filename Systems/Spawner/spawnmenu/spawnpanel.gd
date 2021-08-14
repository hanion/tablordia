extends Panel
# SpawnPanel
signal on_menu_opened()
signal on_menu_closed()


func open_menu() -> void:
	if visible:
		close_menu()
		return
	
	visible = true
	get_node("../..").player.is_blocked_by_ui = true
	get_node("../..").player.get_node("CAM")._lock_movement = true
	emit_signal("on_menu_opened")


func close_menu() -> void:
	visible = false
	get_node("../..").player.is_blocked_by_ui = false
	get_node("../..").player.get_node("CAM")._lock_movement = false
	emit_signal("on_menu_closed")


func _on_CloseButton_pressed():
	close_menu()
