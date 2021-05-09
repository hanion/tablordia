extends Spatial


export(float,0.05,1.0) var tween_duration = 0.1
export(Array,NodePath) var positions := []

var last_world_state_timestamp = 0
var currently_moving := []

onready var player = $player
onready var others = $others
onready var cards = $cards

onready var resource_dispenser = $board/dispenser
onready var item_dispenser = $board/dispenser2



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	NetworkInterface.Main = self
	List.cards_folder = cards
	
	var my_mat = get_player_material(get_tree().get_network_unique_id())
	player.get_node("pointer").set_surface_material(0,my_mat)
	
	# FIXME remove spawning had directly, make it optional
	_spawn_hand(get_tree().get_network_unique_id())
	
	NetworkInterface.request_envs()



func _spawn_player(var pid):
	if pid == get_tree().get_network_unique_id(): return
	if get_node("others").has_node(str(pid)): return
	
	
	var plo = preload("res://scenes/otherPlayer.tscn").instance()
	plo.set_name(str(pid))
	plo.set_network_master(pid)
	
	
	
	var material = get_player_material(pid)
	plo.get_child(0).set_surface_material(0, material)
	
	others.add_child(plo)
	print("M: spawned player and hand, id:",pid)


func get_player_material(id) -> SpatialMaterial:
	var material = SpatialMaterial.new()
	material.albedo_color = List.players[id]["color"] 
	return material


func _spawn_hand(pid) -> void:
	var ph = preload("res://scenes/hand.tscn").instance()
	ph.set_name("hand"+str(pid))
	ph.set_network_master(pid)
	
	var p_rand = get_node(positions[pid%4 -1])
	var phand_rand = p_rand.get_child(0)
	var rand_hand_pos = p_rand.translation + phand_rand.translation
	ph.translation = rand_hand_pos
#	ph.translation = Std.get_global(hand_pos3d)
#	ph.rotation = hand_pos3d.rotation
	
	
	var mat = get_player_material(pid)
	ph.get_node("handMesh").set_surface_material(0, mat)
	
	ph.owner_name = List.players[pid]["name"]
	
	
	cards.add_child(ph)
	
	List.paths[ph.name] = ph.get_path()
	



func process_received_world_state(world_state) -> void:
	# Buffer
	# Interpolate
	# Extrapolate
	if world_state["T"] < last_world_state_timestamp: return
	
	last_world_state_timestamp = world_state["T"]
	Std.erase_t(world_state)
	
	# erase me, i dont want my own update
#	Std.erase_if_has(world_state, NetworkInterface.uid)
	
	# if it was only me, return
	if world_state.empty(): return
	
	
	for id in world_state.keys():
		for key in world_state[id].keys():
			if key == "pointer":
				process_pointer(world_state[id]["pointer"],id)
				continue
#			assert(key != "T","nowTTTT")
			if key == "T":
				continue
			process_obj(world_state[id][key],id,key)
			
		
	
	



func process_obj(obj_state: Dictionary, _id: int, obj_name: String) -> void:
	var obj = Std.get_object(obj_name)
	
	assert(
		obj != null,
		"M: !!! object is null"
		)
	
	if obj_state.has("DO"):
		process_received_dragged_over(
			obj_state["DO"]["d"],
			obj_state["DO"]["o"],
			obj_state["DO"]["p"]
		)
		return
	
	if player.dragging == obj: return
	if _id == NetworkInterface.uid: return
	
	if obj_state.has("R"):
		$Tween.interpolate_property(
		obj,
		"rotation",
		obj.rotation,
		obj_state["R"],
		tween_duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
		)
		$Tween.start()
	
	
	
	if not obj_state.has("O"): return
	
	var trans = obj_state["O"]
	trans = Std.get_local(obj,trans)
	
	
	# For slot, to not make it snap when others moving it
	if obj is br_card:
		if obj.is_in_slot:
			obj.is_in_slot = false
	
	
#	obj.transform.origin = opss[obj_name]["O"]
	$Tween.interpolate_property(
		obj,
		"translation",
		obj.transform.origin,
		trans,
		tween_duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	$Tween.start()




func process_pointer(pointer_state: Dictionary, id: int) -> void:
	if id == NetworkInterface.uid:
		return
	
	if others.has_node(str(id)):
		if not pointer_state.has("O"): return
		move_player_pointer(id,pointer_state["O"])
	else:
		printerr("M: !!! Player doesn't exist in scene,,, spawning")
		_spawn_player(id)



func move_player_pointer(player_id, transform_origin):
	# find puppet pointer
	var player_pointer = others.get_node(str(player_id)).get_node("pointer")
	
	if transform_origin == Vector3(0,0,0): return
	
	$Tween.interpolate_property(
			player_pointer,
			"translation",
			player_pointer.translation,
			transform_origin,
			tween_duration,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN_OUT
	)
	$Tween.start()



func process_received_dragged_over(dragged_name, over_name, pos) -> void:
	var dragged = Std.get_object(dragged_name) as card
	var over = Std.get_object(over_name)
	
	
	if dragged.is_in_dispenser:
		dragged.notify_dispenser()
	
	elif dragged.is_in_trash:
		dragged.in_trash.remove_from_trash(dragged)
	
	elif dragged.is_in_slot:
		dragged.in_slot.remove_from_slot(dragged)
		
	
	elif dragged.is_in_hand:
		if not over is hand:
			print("    ¨removed1 ",dragged_name," from ",dragged.in_hand.name)
			dragged.in_hand.remove_card_from_hand(dragged)
	
	
	
	if over is trash:
		print("    ¨trashed ",dragged_name)
		over.add_to_trash(dragged)
	
	elif over is slot:
		print("    ¨slotted ",dragged_name)
		over.add_to_slot(dragged)
	
	elif over is hand:
		if dragged.is_in_hand:
			if over == dragged.in_hand:
				print("    ¨reordering card prob")
				over.reorder_card(dragged, pos)
			else:
				print("    ¨changed hands")
				dragged.in_hand.remove_card_from_hand(dragged)
				over.add_card_to_hand(dragged, pos)
		else:
			print("    ¨added ",dragged_name," to ",over.name)
			over.add_card_to_hand(dragged, pos)
			
	

	"""
	here
	"""


