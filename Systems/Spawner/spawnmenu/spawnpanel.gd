extends Panel
# SpawnPanel
signal on_menu_opened()
signal on_menu_closed()


func open_menu() -> void:
	if visible:
		close_menu()
		return
	
	visible = true
	Std.is_blocked_by_ui = true
	
	var spawn_button = get_node("vb/mrgn/hs/configurer/Inspector/vb/vsc/SpawnButton")
	spawn_button.disabled = not get_tree().is_network_server()
	emit_signal("on_menu_opened")


func close_menu() -> void:
	visible = false
	Std.is_blocked_by_ui = false
#	get_node("../..").player.get_node("CAM")._lock_movement = false
	emit_signal("on_menu_closed")


func _on_CloseButton_pressed():
	close_menu()
