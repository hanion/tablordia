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
	
	if player.dragging == obj: return
	if _id == NetworkInterface.uid: return
	
	
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
		obj._on_started_dragging_via_network()
	
#	if not currently_processing_do.empty():
#		print("sm: currently processing: ",currently_processing_do)
	if currently_processing_do.has(obj_name):
		print("sm: currently processing: ",currently_processing_do)
		return
	
	var trans = obj_state["O"]
	trans = Std.get_local(obj,trans)
	trans.y = clamp(trans.y,0,100) # genius clamp, cards never go under zero
	
	
	# For slot, to not make it snap when others moving it
	if obj is br_card:
		if obj.is_in_slot:
			obj.is_in_slot = false
	
	
	
	
	
	
	obj.transform.origin = trans
	if obj is deck: obj.set_new_visible_card_translation()
	


	"""
	//||\\ this works NOOOOOOOOOOOO
	IT WAS TWEEN NOOOOOOOOOOOOOOOO

	"""
#	tween.seek(99999)
#	tween.stop_all()
#	tween.interpolate_property(
#		obj,
#		"translation",
#		obj.transform.origin,
#		trans,
#		tween_duration,
#		Tween.TRANS_LINEAR,
#		Tween.EASE_IN_OUT
#	)
#	tween.start()




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




func process_received_do(do) -> void:
	var dragged_name = do["d"]
	var over_name = do["o"]
	var pos = do["p"]
	pos.y = clamp(pos.y,0,100) # genius clamp, cards never go under zero
	
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

	if dragged.is_in_dispenser:
		dragged.notify_dispenser()

	elif dragged.is_in_trash:
		dragged.in_trash.remove_from_trash(dragged)

#	elif dragged.is_in_slot:
#		dragged.in_slot.remove_from_slot(dragged)

	elif dragged.is_in_deck:
		if not over is deck:
			dragged.in_deck.remove_from_deck(dragged)
		if over is deck and not dragged.in_deck == over:
			dragged.in_deck.remove_from_deck(dragged)

#		if not over is hand:
#			hotfix_snap_when_removing_from_hand(dragged)
	
	elif dragged.is_in_hand:
		if not over is hand:
			print("    ¨removed1 ",dragged_name," from ",dragged.in_hand.name)
			dragged.in_hand.remove_card_from_hand(dragged)
			if not over is deck:
				hotfix_snap_when_removing_from_hand(dragged)
	


	if over is trash:
		print("    ¨trashed ",dragged_name)
		over.add_to_trash(dragged)

	elif over is slot:
		print("    ¨slotted ",dragged_name, dragged.is_in_slot)
		over.add_to_slot(dragged)

	elif over is deck:
		if dragged.is_in_deck and dragged.in_deck == over:
			over.order_env()
		else:
			print("    ¨decked ",dragged_name)
			over.add_to_deck(dragged)

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


#	print("<uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu\n\n")
	
	##### remove
	yield(get_tree().create_timer(0.3),"timeout")
	currently_processing_do.erase(dragged_name)




func hotfix_snap_when_removing_from_hand(var crd):
#	"""
	
#	TODO: wtf bro 
#		it flicks when dragged out of hand
	
	var __a = crd.translation
	for i in range(10):
		yield(get_tree().create_timer(0.005),"timeout")
		var diff = __a - crd.translation
		
		if diff.x > 0.01 or diff.z > 0.01:
#			prints(__a,crd.translation, i, diff)
			crd.translation=__a
			continue
		
		if diff.x < 0.01 and diff.z < 0.01:
			prints("			'nosnap took ",i)
			break
#	"""
	
	"""
	var __pos0 = crd.translation
	yield(get_tree().create_timer(0.01559),"timeout")
	crd.translation = __pos0
	"""

