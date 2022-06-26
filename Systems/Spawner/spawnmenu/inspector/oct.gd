extends CheckBox
# oct

signal oct_checked(val)


func _on_oct_toggled(button_pressed: bool) -> void:
	emit_signal("oct_checked",button_pressed)
