extends ScrollContainer

func scroll_to_end() -> void:
	yield(get_tree().create_timer(0.2),"timeout")
	scroll_vertical = 9999999
