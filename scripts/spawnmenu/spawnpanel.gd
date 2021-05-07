extends Panel
# SpawnPanel



func open_menu() -> void:
	if visible:
		close_menu()
		return
	
	visible = true
	get_node("../..").player.is_blocked_by_ui = true
	get_node("../..").player.get_node("CAM")._lock_movement = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func close_menu() -> void:
	visible = false
	get_node("../..").player.is_blocked_by_ui = false
	get_node("../..").player.get_node("CAM")._lock_movement = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	


func _on_CloseButton_pressed():
	close_menu()
