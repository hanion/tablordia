extends ScrollContainer



func _on_m1_pressed():
	get_parent().get_parent().selected("br", "misc", "BoardRoyale", 1)


func _on_m2_pressed():
	get_parent().get_parent().selected("Board", "Board","Chess Board",1)
