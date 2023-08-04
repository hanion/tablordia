extends Node


var cleared_twice = false
func remove_all() -> void:
	for obj_name in List.paths.keys():
		if not List.paths.has(obj_name): continue
		if obj_name == "table": continue
		remote_remove_objects(obj_name)
	
	if not cleared_twice:
		cleared_twice = true
		
		remove_all()
		
		yield(get_tree().create_timer(5),"timeout")
		cleared_twice = false





func remote_remove_objects(object_name : String) -> void:
	rpc_config("_remote_to_local_remove_object",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rpc_id(0,"_remote_to_local_remove_object",object_name)

remote func _remote_to_local_remove_object(object_name : String) -> void:
	remove_object(object_name) 

func remove_object(object_name : String) -> void:
	if not List.paths.has(object_name): return
	
	var object = get_node(List.paths[object_name])
	if not object: return
	if not is_instance_valid(object): return
	
	
	if not __object_checks(object): return
	
	print(" - removing object (",object_name,")")
	UMB.log(3,"cmd", "Removed object (" + object_name + ")")
	
	
# warning-ignore:return_value_discarded
	List.paths.erase(object_name)
	object.queue_free()



func __object_checks(object) -> bool:
	if object is card:
		
		if object.is_in_hand:
			if not is_instance_valid(object.in_hand):
				print("!trying to remove an object in_hand and hand is not valid, "+object.name)
				return true
			
			object.in_hand.remove_card_from_hand(object)
		
		elif object.is_in_deck:
			if not is_instance_valid(object.in_deck):
				print("!trying to remove an object in_deck and deck is not valid, "+object.name)
				return true
			
			object.in_deck.remove_from_deck(object)
		
		elif object.is_in_dispenser:
			if not is_instance_valid(object.in_dispenser):
				print("1trying to remove an object in_dispenset and dispenser is not valid, "+object.name)
				return true
			
			object.in_dispenser.notify()
		
		elif object.is_in_slot:
			if not is_instance_valid(object.in_slot):
				print("!trying to remove an object in_slot and slot is not valid, "+object.name)
				return true
			
			object.in_slot.remove_from_slot(object)
		
		elif object.is_in_trash:
			if not is_instance_valid(object.in_trash):
				print("!trying to remove an object in_trash and trash is not valid, "+object.name)
				return true
			
			object.in_trash.remove_from_trash(object)
	
	
	
	elif object is hand:
		for in_hand_obj in object.inventory:
			if not is_instance_valid(in_hand_obj): continue
			print("	 - removing child:")
			remove_object(in_hand_obj.name)
	
	
	elif object is deck or object is trash:
		for in_deck_obj in object.env:
			if not is_instance_valid(in_deck_obj): continue
			remove_object(in_deck_obj.name)
	
	
	elif object is slot:
		if is_instance_valid(object.env):
			remove_object(object.env.name)
	
	return true
