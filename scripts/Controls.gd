extends Spatial

var ctrl_held_down := false
var shift_held_down := false

onready var cam = get_node("../CAM")
onready var spawn_panel = get_node("../../CanvasLayer/SpawnPanel")

func _unhandled_key_input(event:InputEventKey):
	handle_control(event)
	handle_shift(event)
	handle_spawnmenu(event)


func _input(event:InputEvent):
	if OS.has_touchscreen_ui_hint(): 
		handle_touch(event)
		return
	
	handle_pan(event)
	handle_rotation(event)
	handle_zoom(event)
	handle_rcm(event)

###
var rc_mode : bool = false
func handle_touch(_event) -> void:
	if rc_mode:
		var obj = get_parent().cast_ray()
		if obj["collider"]:
			RCM.right_clicked(obj["collider"])
	
###


func handle_control(event) -> void:
	if event.is_action_pressed("ctrl"):
		ctrl_held_down = true
	elif event.is_action_released("ctrl"):
		ctrl_held_down = false


func handle_shift(event) -> void:
	if event.is_action_pressed("shift"):
		shift_held_down = true
	elif event.is_action_released("shift"):
		shift_held_down = false



func handle_spawnmenu(event) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("spawn_menu"):
			if spawn_panel.visible:
				spawn_panel.close_menu()
			else:
				spawn_panel.open_menu()
			



func handle_pan(event) -> void:
	if not ctrl_held_down:
		cam.is_panning = false
		return
	
	if event.is_action_pressed("left_mouse"):
		cam.is_panning = true
		cam._last_mouse_position = get_viewport().get_mouse_position()
	elif event.is_action_released("left_mouse"):
		cam.is_panning = false


func handle_rotation(event) -> void:
	if not ctrl_held_down:
		cam.is_rotating = false
		return
	
	if event.is_action_pressed("right_mouse"):
		cam.is_rotating = true
		cam._last_mouse_position = get_viewport().get_mouse_position()
	elif event.is_action_released("right_mouse"):
		cam.is_rotating = false


func handle_zoom(event) -> void:
	if not ctrl_held_down:
		cam.zoom_direction = 0
		return
	
	if event.is_action_pressed("camera_zoom_in"):
		cam.zoom_direction = -1
	if event.is_action_pressed("camera_zoom_out"):
		cam.zoom_direction = 1


func handle_rcm(event) -> void:
	if ctrl_held_down: return
	if shift_held_down: return
	
	if event.is_action_pressed("right_mouse"):
		var obj = get_parent().cast_ray()
		if obj["collider"]:
			RCM.right_clicked(obj["collider"])
		
	elif event.is_action_released("right_mouse"):
		pass

