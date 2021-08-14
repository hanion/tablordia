extends Button


onready var controls = get_node("../../../player").get_node("Controls")

func _on_Button_pressed():
	controls.rc_mode = not controls.rc_mode
