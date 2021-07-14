extends Button



func _on_out_pressed():
	UMB.chat_closed()
	visible = false
	


func _on_input_field_focus_entered():
	UMB.chat_opened()
	visible = true
