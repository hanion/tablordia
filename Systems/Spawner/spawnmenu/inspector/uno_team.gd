extends HBoxContainer
# uno_team

signal color_changed(a)


func _on_OptionButton_item_selected(index):
	emit_signal("color_changed",index)
