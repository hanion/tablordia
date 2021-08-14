extends ScrollContainer

func scroll_to_end() -> void:
	yield(get_tree().create_timer(0.01),"timeout")
	scroll_vertical = 9999999
