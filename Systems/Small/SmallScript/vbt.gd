extends VBoxContainer

onready var controls = get_node("../../player/Controls")


func _ready() -> void:
	if not OS.has_touchscreen_ui_hint(): hide()

func _on_b_rcm_toggled(button_pressed: bool) -> void:
	controls.rc_mode = button_pressed


func _on_b_r_toggled(button_pressed: bool) -> void:
	controls.rotate_mode = button_pressed


func _on_b_s_toggled(button_pressed: bool) -> void:
	controls.shift_mode = button_pressed
