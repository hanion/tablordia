extends Node


var world_state = {}
var world_state_collection = {}
export(int) var update_frame_time = 4

func _physics_process(_delta):
	if not get_tree().has_network_peer(): return
	# if we are not the host, delete processor
	if not get_tree().is_network_server(): 
		queue_free()
		return
	
	
	if _has_been_20_fps():
#		print("**sending do _pp")
		process_world_state()



func process_world_state():
	if get_parent().world_state_up.empty(): return
	
	world_state = get_parent().world_state_up.duplicate(true)
	
	
	remove_redundant_and_save_to_collection()
	get_parent().world_state_up.clear()
	
	if world_state.empty(): return
	
	
	
	###########################################################################
	# Anti cheat
	# checks
	world_state["T"] = OS.get_system_time_msecs()
	var going_world_state = world_state.duplicate(true)
	get_parent().send_processed_world_state_to_client(going_world_state)
	###########################################################################


# removes items   if last_world_state contains and identical to new ones
# removes "T" from world_state before sending to client
func remove_redundant_and_save_to_collection() -> void:
	if world_state_collection.empty():
		world_state_collection = world_state.duplicate(true)
		return
	
#	print("\nupws:\n",world_state)
#	print("\nwsc:\n",world_state_collection)
	for id in world_state.keys():
		rr_from_id(id)
		
		for key in world_state[id].keys():
			if key == "T": continue
			rr_from_key(id,key)
			
			for subkey in world_state[id][key].keys():
				rr_from_subkey(id,key,subkey)
				
			
			Std.erase_if_empty(world_state[id],key)
		
		Std.erase_if_empty(world_state,id)
		
	
#	if not world_state.empty():
#		print("\nws--------:\n",world_state)
	

func rr_from_id(id) -> void:
	if not world_state_collection.has(id):
		world_state_collection[id] = world_state[id].duplicate(true)
#		continue
	
	
	if world_state_collection[id]["T"] > world_state[id]["T"]:
		world_state.erase(id)
		print("noo")
		return
	
	Std.erase_t(world_state[id])


func rr_from_key(id,key) -> void:
	if key == "T":
		world_state_collection[id]["T"] = world_state[id]["T"]
		Std.erase_t(world_state[id])
		return
	
	if not world_state_collection[id].has(key):
		world_state_collection[id][key] = world_state[id][key].duplicate(true)
		return


func rr_from_subkey(id,key,subkey) -> void:
	if subkey == "DO":
		rr_from_do(id,key)
		return
	
	if not Std.has_all(world_state_collection,id,key,subkey):
		world_state_collection[id][key][subkey] = world_state[id][key][subkey]
		return
	
	if world_state_collection[id][key][subkey] == world_state[id][key][subkey]:
		world_state[id][key].erase(subkey)
		return
	
	world_state_collection[id][key][subkey] = world_state[id][key][subkey]



func rr_from_do(id,key) -> void:
	
	if not world_state_collection[id][key].has("DO"):
		world_state_collection[id][key]["DO"] = world_state[id][key]["DO"].duplicate(true)
		return
	
	var ws_p = world_state[id][key]["DO"]["p"]
	var wsc_p = world_state_collection[id][key]["DO"]["p"]
	
	if ws_p == wsc_p:
		world_state[id][key].erase("DO")
		return
	
	world_state_collection[id][key]["DO"] = world_state[id][key]["DO"].duplicate(true)
	world_state_collection[id][key].erase("DO")
#	world_state[id][key].erase("DO")
	






var _frames := 0
func _has_been_20_fps() -> bool:
	_frames += 1
	if _frames%update_frame_time == 0:
		_frames = 0
		return true
	return false
