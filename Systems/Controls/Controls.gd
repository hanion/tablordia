extends Spatial

var ctrl_held_down := false
var shift_held_down := false

onready var camera = get_node("../CAM")
onready var spawn_panel = get_node("../../CanvasLayer/SpawnPanel")
onready var ccs = get_node("../CCS")

func _unhandled_key_input(event:InputEventKey):
	handle_control(event)
	handle_shift(event)
	handle_spawnmenu(event)
	handle_settings_ui(event)


func _input(event:InputEvent):
	if OS.has_touchscreen_ui_hint(): 
		handle_touch(event)
		return
	
	if Std.is_blocked_by_ui: return
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
		ccs.change_icon("cam")
	elif event.is_action_released("ctrl"):
		ccs.change_icon()
		ctrl_held_down = false


func handle_shift(event) -> void:
	if event.is_action_pressed("shift"):
		shift_held_down = true
		ccs.change_icon("hand")
	elif event.is_action_released("shift"):
		shift_held_down = false
		ccs.change_icon()



func handle_spawnmenu(event) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("spawn_menu"):
			if spawn_panel.visible:
				spawn_panel.close_menu()
			else:
				spawn_panel.open_menu()
			



func handle_pan(event) -> void:
	if not ctrl_held_down:
		camera.is_panning = false
		return
	
	if event.is_action_pressed("left_mouse"):
		camera.is_panning = true
		camera._last_mouse_position = get_viewport().get_mouse_position()
		ccs.change_icon("cammove")
	elif event.is_action_released("left_mouse"):
		camera.is_panning = false
		ccs.change_icon("cam")


func handle_rotation(event) -> void:
	if not ctrl_held_down:
		camera.is_rotating = false
		return
	
	if event.is_action_pressed("right_mouse"):
		camera.is_rotating = true
		camera._last_mouse_position = get_viewport().get_mouse_position()
		ccs.change_icon("camrotate")
	elif event.is_action_released("right_mouse"):
		camera.is_rotating = false
		ccs.change_icon("cam")


func handle_zoom(event) -> void:
	if not ctrl_held_down:
		camera.zoom_direction = 0
		return
	
	if event.is_action_pressed("camera_zoom_in"):
		camera.zoom_direction = -1
	if event.is_action_pressed("camera_zoom_out"):
		camera.zoom_direction = 1


func handle_rcm(event) -> void:
	if ctrl_held_down: return
	if shift_held_down: return
	
	if event.is_action_pressed("right_mouse"):
		var obj = get_parent().cast_ray()
		if obj and obj["collider"]:
			RCM.right_clicked(obj["collider"])
		
	elif event.is_action_released("right_mouse"):
		pass


func handle_settings_ui(event) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("settings_ui"):
			if SettingsUI.visible:
				SettingsUI.close_ui()
			else:
				SettingsUI.open_ui()
			





