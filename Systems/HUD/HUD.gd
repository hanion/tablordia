extends Control

var player


func _on_cam_toggled(button_pressed):
	player.Controls.ctrl_held_down = button_pressed
	player.Controls.ccs.is_showing = button_pressed
	if button_pressed:
		player.Controls.ccs.change_icon("cam")
	else:
		player.Controls.ccs.change_icon("nothing")
	


func _on_movemore_toggled(button_pressed):
	player.Controls.shift_held_down = button_pressed
	player.Controls.ccs.is_showing = button_pressed
	if button_pressed:
		player.Controls.ccs.change_icon("hand")
	else:
		player.Controls.ccs.change_icon("nothing")
	



func _on_esc_pressed():
	SettingsUI.open_ui()







