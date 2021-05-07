extends Spatial

signal stopped_dragging()
signal started_dragging(obj)



export(int) var ray_length = 100
export(float, 0.1, 359.9, 0.1) var rotatiton_one_tick = 1.0

# current_cast 
var current = null # is cast
# object we are currently holding
var dragging = null # is node
var is_dragging := false # is state
var _dragging_offset: Vector3

var is_rotated := false
var is_blocked_by_ui := false

var _do_is_dragged_over: bool = false
var _do_dragged: String
var _do_over: String
var _do_pos: Vector3

onready var camera = $CAM/position/elevation/zoom/Camera
onready var pointer = $pointer as Spatial
onready var close_up = $CAM/position/elevation/zoom/Camera/closeup as Spatial
onready var oer = get_node("../oer") as Spatial
onready var spawn_menu = get_node("../CanvasLayer/SpawnPanel")



func _input(event):
	if is_blocked_by_ui: return
	if cast_ray():
		move_pointer()
		manage_dragging(event)
		manage_rotating(event)
		manage_look_closeup(event)
		manage_oable(event)

func _physics_process(_delta):
	if is_dragging:
		drag()


#######################
# 	FUNCTIONS 
#######################
func cast_ray():
	# mouse position
	var mouse = get_viewport().get_mouse_position()
	# starting point of ray
	var from = camera.project_ray_origin(mouse)
	# ending point of ray
	var to = from + camera.project_ray_normal(mouse) * ray_length
	
	
	
	# casting ray
	var cast = camera.get_world().direct_space_state.intersect_ray(
		from,to,
		# if we are currently dragging an object,
		## we dont want our cast to hit it
		## we want our cast to hit behind the object
		[dragging] if is_dragging else [],
		# in case the dragging objects collision mask is different
		dragging.get_collision_mask() if is_dragging else 2147483647,
		# we want cast to intersect with both rigidbody and area
		true,true
		)
	
	## cast has object we are hovering or has mouse intersecting with ground 
	## and cast has target position
	current = cast
	return current



func move_pointer() -> void:
	var pointing_at = current["position"] as Vector3
#		$Tween.interpolate_property(pointer,"translation",pointer.translation,
#		pointing_at,0.06,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
#		$Tween.start()
	pointer.translation = pointing_at
	
	define_pointer_state(pointing_at)


func manage_dragging(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				
				drag_start()
				
			else:
				if not is_dragging: return
				drag_stop()


func manage_rotating(event) -> void:
	if event is InputEventKey:
		if current['collider']:
			if event.is_action_pressed("rotate_object"):
				rotate_one_tick(current['collider'])
			elif event.is_action_pressed("rotate_object_reverse"):
				rotate_one_tick(current['collider'],true)


func manage_look_closeup(event) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("look_closeup"):
			if current['collider']:
				close_up.look_closeup(current['collider'],true)
		if event.is_action_released("look_closeup"):
			close_up.look_closeup(current['collider'],false)


func manage_oable(event) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("spawn_menu"):
			spawn_menu.open_menu()
		
		if current['collider']:
			if event.is_action_pressed("oable"):
				oer.o(current['collider'])



func rotate_one_tick(obj, is_reverse := false) -> void:
	if not obj.is_in_group("rotatable"): return
	
	var dir = -1 if is_reverse else 1
	
	obj.rotate_y(deg2rad(rotatiton_one_tick*dir))
	define_obj_rotation_state(obj)








func drag_start() -> void:
	dragging = current['collider']
	if not dragging.is_in_group("draggable"): return
	
	
	var card_translation = dragging.translation
	var cast_translation = current["position"]
	
	var angle = dragging.get_parent().rotation.y
	
	# relative = global
	var relative_translation = Std.complex_rotate_reverse(card_translation,angle)
	
	var offset_from_center = relative_translation - cast_translation
	
	
	offset_from_center = Std.complex_rotate(offset_from_center,angle)
	
	var off_y #= dragging.col.shape.extents.y
	off_y = dragging.off_y
	var siz_y = dragging.col.scale.y
	_dragging_offset = (Vector3(0,off_y*siz_y,0) + offset_from_center)
	
	is_dragging = true
	cast_ray()
	emit_signal("started_dragging",dragging)


# called from _physics_process every frame while is_dragging is true
func drag() -> void:
	if not current: return
	if not dragging.is_in_group("draggable"): return
	
	if dragging is RigidBody:
	# if we are dragging a rigidbody we need to wake it
	## and clear its linear velocity because:
	### it builds up gravitational force when held in air
	### we want to clear that velocity
		dragging.sleeping = false
		dragging.linear_velocity = Vector3.ZERO
	
	
	
	# target position of dragging object
	# current['position'] = position of mouse intersecting with something
	var trgt = (current['position'] - get_parent().translation) 
	
	var new_coord = Std.complex_rotate(trgt, dragging.get_parent().rotation.y)
	new_coord += Vector3(0,0.04,0) + _dragging_offset
	
	# translating object to desired location
	dragging.set_translation(new_coord)
	
	# send loc
	define_obj_state(dragging) 


func drag_stop() -> void:
#	if dragging is deck:
#		dragging.stopped_dragging()
	emit_signal("stopped_dragging")
	
	dragged_over(dragging, current['collider'], current['position'])
	
	
	
	is_dragging = false
	clear_dragging_after_delay()


func clear_dragging_after_delay() -> void:
	yield(get_tree().create_timer(0.3),"timeout")
	if is_dragging: return
	if not dragging: return
	
	# TODO remove this shit, use global translations
#	define_obj_state(dragging)
#	update_object_state(dragging)
	dragging = null


func dragged_over(var dragged: card,var over: Spatial,var pos: Vector3) -> void:
	if dragged == null: return
	if over == null: return
	
	if not _should_send(dragged,over): return
	
	_do_dragged = dragged.name
	_do_over = over.name
	_do_pos = pos as Vector3
	_do_is_dragged_over = true
	print("dragged over")
	define_obj_state(dragged)

func _should_send(drgd: card, ovr) -> bool:
	if drgd.is_in_hand: return true
	if drgd.is_in_dispenser: return true
	if drgd.is_in_trash: return true
	if drgd.is_in_slot: return true
	if drgd.in_slot: return true
	
	if ovr is hand: return true
	if ovr is trash: return true
	if ovr is slot: return true
	
	return false
















func define_pointer_state(origin: Vector3) -> void:
	var state = {
		"pointer":{
			"O": origin
		}
	}
	NetworkInterface.collect_state(state)

func define_obj_state(drgn, _tr = Vector3(0,0,0)) -> void:
	if _tr == Vector3(0,0,0):
		_tr = Std.get_global(drgn)
	
	var state = {
		drgn.name:{
			"O": _tr
		}
	}
	
	if _do_is_dragged_over:
		state[drgn.name]["DO"] = {
			"d":_do_dragged,
			"o":_do_over,
			"p":_do_pos
		}
		_do_is_dragged_over = false
	
	
	NetworkInterface.collect_state(state)


func define_obj_rotation_state(obj) -> void:
	var state = {
		obj.name:{
			"R":obj.rotation
		}
	}
	
	NetworkInterface.collect_state(state)
