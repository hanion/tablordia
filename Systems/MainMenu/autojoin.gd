extends Button

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("chat_cmd"):
		visible = not visible
