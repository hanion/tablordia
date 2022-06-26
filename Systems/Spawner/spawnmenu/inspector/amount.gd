extends HBoxContainer
# amount

signal amount_changed(am)

func _on_SpinBox_value_changed(value) -> void:
	emit_signal("amount_changed",int(value))
