extends HBoxContainer

export(NodePath) onready var cam = get_node(cam) as ToolButton
export(NodePath) onready var movemore = get_node(movemore) as ToolButton


func _on_cam_toggled(button_pressed):
	if button_pressed:
		movemore.pressed = false


func _on_movemore_toggled(button_pressed):
	if button_pressed:
		cam.pressed = false

