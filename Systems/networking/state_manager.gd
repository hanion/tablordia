extends Spatial

export(float,0.05,1.0) var tween_duration = 0.1

var currently_processing_do := []

onready var player = get_node("../player")
onready var others = get_node("../others")
var last_world_state_timestamp = 0
onready var tween = $Tween

func process_received_world_state(world_state:Dictionary) -> void:
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
	
	assert(obj != null, "M: !!! object is null")
	
	# the received object does not exist here FIXME
	
	if player.dragging == obj: return
	if _id == NetworkInterface.uid: return
	
	
#	STATE.set_last_state(obj_name, obj_state)
	
	
	if obj_state.has("R"):
		obj.rotation = obj_state["R"]
		
#		tween.interpolate_property(
#		obj,
#		"rotation",
#		obj.rotation,
#		obj_state["R"],
#		tween_duration,
#		Tween.TRANS_LINEAR,
#		Tween.EASE_IN_OUT
#		)
#		tween.start()
	
	
	
	if not obj_state.has("O"): return
	
	if obj is RigidBody:
		obj.sleeping = false
		obj.linear_velocity = Vector3.ZERO
	if obj is StaticBody:
		if obj.has_method("_on_started_dragging_via_network"):
			obj._on_started_dragging_via_network()
	
	if currently_processing_do.has(obj_name):
		return
	
	var trans = obj_state["O"]
	trans = Std.get_local(obj,trans)
	trans.y = clamp(trans.y,0,100) # genius clamp, cards never go under zero
	
	
	# For slot, to not make it snap when others moving it
	if obj is br_card:
		if obj.is_in_slot:
			obj.is_in_slot = false
	
	
	obj.transform.origin = trans


func process_pointer(pointer_state: Dictionary, id: int) -> void:
	if id == NetworkInterface.uid:
		return
	
	if others.has_node(str(id)):
		if not pointer_state.has("O"): return
		move_player_pointer(id,pointer_state["O"])
	else:
		printerr("M: !!! Player doesn't exist in scene,,, spawning")
		get_parent()._spawn_player(id)



func move_player_pointer(player_id, transform_origin):
	# find puppet pointer
	var player_pointer = others.get_node(str(player_id)).get_node("pointer")
	
	if transform_origin == Vector3(0,0,0): return
	
	tween.interpolate_property(
			player_pointer,
			"translation",
			player_pointer.translation,
			transform_origin,
			tween_duration,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN_OUT
	)
	tween.start()



func process_received_do(do) -> bool:
	var dragged_name = do["d"]
	var over_name = do["o"]
	var pos = do["p"]
	pos.y = clamp(pos.y,0,100) # genius clamp, cards never go under zero
	
#	STATE.set_last_do_state(dragged_name, do)
	
	
	##### add
	currently_processing_do.append(dragged_name)
	
	var dragged = Std.get_object(dragged_name) as card
	var over = Std.get_object(over_name) as Spatial
	print(" + rdo      ",
	"        d:",dragged_name,
	",        o:",over_name,
	",        p:",pos
	)
	
	
#	tween.stop_all()
	
	if not dragged or not is_instance_valid(dragged): 
		return false


	if dragged.is_in_container:
		if not is_instance_valid(dragged.in_container):
			print("	nooo instance is not valid of dragged in s do 9898")
			return false
		
		if not dragged.in_container == over: 
			var _result = dragged.in_container.remove_card_from_container(dragged)

#	elif dragged.is_in_slot:
#		dragged.in_slot.remove_from_slot(dragged)


	elif dragged.is_in_hand:
		if not over is hand:
#			print("    ¨removed1 ",dragged_name," from ",dragged.in_hand.name)
			if is_instance_valid(dragged.in_hand):
				dragged.in_hand.remove_card_from_hand(dragged)
#				if not over is deck:
#					hotfix_snap_when_removing_from_hand(dragged)
	


	if over is container:
		if dragged.is_in_container and dragged.in_container == over:
			over.order_env()
		else:
			if not over.add_card_to_container(dragged):
				dragged.set_is_hidden(false)

	elif over is slot:
#		print("    ¨slotted ",dragged_name, dragged.is_in_slot)
		over.add_to_slot(dragged)


	elif over is hand:
		if dragged.is_in_hand:
			if over == dragged.in_hand:
#				print("    ¨reordering card prob")
				over.reorder_card(dragged, pos)
			else:
#				print("    ¨changed hands")
				dragged.in_hand.remove_card_from_hand(dragged)
				over.add_card_to_hand(dragged, pos)
		else:
#			print("    ¨added ",dragged_name," to ",over.name)
			over.add_card_to_hand(dragged, pos)
	
	# over is nothing: table
	else:
		# every card in table is not hidden
		dragged.set_is_hidden(false)
		dragged.set_collision_layer_bit(0,true)
	

#	print("<uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu\n\n")
	
	##### remove
	yield(get_tree().create_timer(0.3),"timeout")
	currently_processing_do.erase(dragged_name)
	
	return true



func hotfix_snap_when_removing_from_hand(var crd: card):
#		it flicks when dragged out of hand
	
	var __a = crd.translation
	for i in range(10):
		yield(get_tree().create_timer(0.005),"timeout")
		
		if crd.is_in_container: return
		
		var diff = __a - crd.translation
		
		if diff.x > 0.01 or diff.z > 0.01:
			crd.translation=__a
			continue
		
		if diff.x < 0.01 and diff.z < 0.01:
			prints("			'nosnap took ",i)
			break


