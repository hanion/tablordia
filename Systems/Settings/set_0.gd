extends Control
signal option_button_item_selected(index)
signal check_box_toggled(val)
signal h_slider_value_changed(value)
signal spin_box_value_changed(value)

func _on_set_check_box_toggled(button_pressed):
	emit_signal("check_box_toggled",button_pressed)


func _on_set_option_button_item_selected(index):
	emit_signal("option_button_item_selected",index)


func _on_set_h_slider_value_changed(value):
	emit_signal("h_slider_value_changed",value)


func _on_set_spin_box_value_changed(value):
	emit_signal("spin_box_value_changed",value)
