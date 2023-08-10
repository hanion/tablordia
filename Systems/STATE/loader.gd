extends Node


# TODO load containers and hands first
# when cards are spawning, they want to be attached to a container of hand
# and that container or hand does not exist yet

var state_manager : Spatial


func LOAD_STATE(WS : Dictionary) -> void:
	print("\n	LOAD STATE")
	get_parent().WORLD_STATE = WS.duplicate(true)
	
	state_manager = get_node("/root/Main/state_manager")
	
	var sorted_keys_array : Array = []
	
	print("		WORLD STATE  keys count = ", WS.size()-1)
	
	for key in WS.keys():
		if key == "id": continue
		sorted_keys_array.append(key)
	
	# sort cards to last
	for key in sorted_keys_array:
		if not WS[key].has("spawn_type"): continue
		
		if WS[key]["spawn_type"] == "Card":
			sorted_keys_array.erase(key)
			sorted_keys_array.append(key)
	
	print("		sorted array keys count = ", sorted_keys_array.size())
	
	# load sorted
	for key in sorted_keys_array:
#		yield(get_tree().create_timer(0.5),"timeout")
		load_obj(WS[key])
	
	print("	LOAD STATE	WORLD STATE loaded.")
	UMB.log(1,"STATE","Loaded World State")



func load_obj(state : Dictionary) -> void:
	if does_not_have(state, "name"): return
	if does_not_have(state, "spawn_type"): return
#	if does_not_have(state, "spawn_name"): return
	
	
	var info  = {
		"type":         state["spawn_type"],
		"spawned_name": state["name"],
		"amount":       1,
		"do_not_init":  true
		}
	
	if state.has("spawn_name"):
		info["name"] = state["spawn_name"]

	
	add_if_has(info, state, "value")
	add_if_has(info, state, "value_second")
	
	add_if_has(info, state, "is_in_container")
	add_if_has(info, state, "in_container")
	add_if_has(info, state, "in_container_index")
	
	add_if_has(info, state, "is_in_hand")
	add_if_has(info, state, "in_hand")
	add_if_has(info, state, "in_hand_index")
	add_if_has(info, state, "owner_id")
	add_if_has(info, state, "owner_name")
	add_if_has(info, state, "others_can_touch")
	
	
	
	
	
	var result = Spawner._spawn(info)
	var obj = result
	
	
	if not obj or not is_instance_valid(obj):
		push_error(" - STATE::loader: spawned obj is invalid!")
		return
	
	if obj is GDScriptFunctionState:
		prints("!!!	!!!	!!!	obj is GDScriptFunctionState",obj)
		prints("!!!	!!!	!!!	probably hand without an owner")
		return
	
	
	
	
	yield(get_tree().create_timer(0.1),"timeout")
	
	if state.has("transform"):
		obj.transform = state["transform"]
	
	
	if obj.name != info["spawned_name"]:
		prints("not same", obj.name, info["spawned_name"])
		return
#	print(" + SPAWNER::loader: spawned object ",obj.name, " ", info["name"])
	
	
	# set in container and in hands
	if obj is card:
		load_data_to_card(obj, state)
	elif obj is container:
		load_data_to_container(obj, state)


func load_data_to_card(crd: card, state : Dictionary) -> void:
	if not crd or not is_instance_valid(crd): return
	
	if state.has("is_in_container") and state["is_in_container"] \
		and state.has("in_container") and state["in_container"]:
		
		var in_con : container = Std.get_object(state["in_container"])
		
		if not in_con or not is_instance_valid(in_con):
			return
		
		
		# should we do this or in_con.add_card_to_container(obj)
		crd.is_in_container = true
		crd.in_container = in_con
	
	
	elif state.has("is_in_hand") and state["is_in_hand"] \
		and state.has("in_hand") and state["in_hand"]:
		
		var in_han : hand = Std.get_object(state["in_hand"])
		
		if not in_han or not is_instance_valid(in_han):
			return
		
		
		# should we do this or in_con.add_card_to_container(obj)
		in_han.add_card_to_hand(crd,crd.translation)


func load_data_to_container(con: container, _state : Dictionary) -> void:
	if not con or not is_instance_valid(con): return
	
#	if state.has("data_inv") and state["data_inv"]:
#		con.data_inv = state["data_inv"]
#
	con.ask_for_data()









func does_not_have(state : Dictionary, key : String) -> bool:
	if not state.has(key): 
		push_error("STATE::loader: state does not have " + key)
		return true
	return false


func add_if_has(add_to : Dictionary, add_from : Dictionary, key : String) -> void:
	if not add_from.has(key): return
	add_to[key] = add_from[key]







