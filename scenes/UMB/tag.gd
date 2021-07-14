extends CheckBox
signal tag_toggled(toggle,txt)


func _on_tag_toggled(button_pressed):
	emit_signal("tag_toggled",button_pressed,self.text)
