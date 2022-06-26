extends Control

var player
var spawn_panel


func _on_cam_toggled(button_pressed):
	player.Controls.ctrl_held_down = button_pressed
	player.Controls.ccs.is_showing = button_pressed
	if button_pressed:
		player.Controls.ccs.change_icon("cam")
	else:
		player.Controls.ccs.change_icon("nothing")



func _on_esc_pressed():
	SettingsUI.open_ui()


func _on_spawn_panel_m_pressed() -> void:
	if spawn_panel: spawn_panel.open_menu()
