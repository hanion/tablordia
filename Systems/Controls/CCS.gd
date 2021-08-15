# Custom Cursor System
extends Control

onready var img = $texture

var is_showing := false

const cr_cam = preload("res://assets/cursors/Camera2D.png")
const cr_move = preload("res://assets/cursors/ToolMove.png")
const cr_rotate = preload("res://assets/cursors/ToolRotate.png")
const cr_hand = preload("res://assets/cursors/pan.png")


class mode:
	enum model {
		cam,
		cammove,
		camrotate,
		hand,
		nothing
	}


func change_icon(_mode : String = "nothing") -> void:
	move_img()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	is_showing = true
	visible = true
	
	match _mode:
		"cam":
			img.texture = cr_cam
		"cammove":
			img.texture = cr_move
		"camrotate":
			img.texture = cr_rotate
		"hand":
			img.texture = cr_hand
		
		
		
		
		"nothing":
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			is_showing = false
			visible = false



func _input(event):
	if not event is InputEventMouseMotion: return
	if not is_showing: return
	move_img()


func move_img() -> void:
	img.set_position(get_global_mouse_position()-Vector2(20,20))


