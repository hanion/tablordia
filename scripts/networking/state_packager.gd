extends Node

var update_frame_time := 2
var state_collection := {}
var uid := 0


var new_state := {}
var packed_state_collection := {}


var _state := {
	"pointer":{
		"O":"transform.origin",
		"R":"rotation"
	},
	"object_name":{
		"O":"transform.origin",
		"R":"rotation"
	}
}

func collect_state(state: Dictionary) -> void:
	if state.has("pointer"):
		new_state["pointer"] = state["pointer"].duplicate(true)
	else:
		for obj_name in state.keys():
#			print("-object : ",obj_name)
			new_state[obj_name] = state[obj_name].duplicate(true)



func _physics_process(_delta):
	if _has_been_20_fps():
		var packaged_state = package_state()
		
		if not packaged_state: return
		
#		print("\nPACKAGED SUCCESSFULLY, \n",packaged_state)
#		print("\n\n\n\n\npkstate.:",packaged_state)
		send_packaged_state(packaged_state)




func package_state():
	if state_collection.empty():
		state_collection = new_state.duplicate(true)
#		return
	
	for key in new_state.keys():
		package_key(key)
		
		for subkey in new_state[key].keys():
			package_subkey(key,subkey)
		
		Std.erase_if_empty(new_state,key)
	
	if new_state.empty(): return
	
	# package under our id
	var packaged_state := {
		uid:new_state.duplicate(true)
	}
	packaged_state[uid]["T"] = OS.get_system_time_msecs()
	return packaged_state


func package_key(key) -> void:
	if not state_collection.has(key):
		state_collection[key] = new_state[key].duplicate(true)
		return


func package_subkey(key,subkey) -> void:
	if subkey == "DO":
		package_do(key)
		return
	
	
	if not subkey == "R" and not subkey == "O":
		assert(
			Std.has_all(state_collection,key,subkey),
			"state_collection must have subkey"
		)
	
	if not state_collection[key].has(subkey):
		state_collection[key][subkey] = new_state[key][subkey]
		return
	
	if state_collection[key][subkey] == new_state[key][subkey]:
		new_state[key].erase(subkey)
		return
	
	state_collection[key][subkey] = new_state[key][subkey]


func package_do(key) -> void:
#	if new_state[key].has("O"):
#		new_state[key].erase("O")
	
	if not state_collection[key].has("DO"):
		state_collection[key]["DO"] = new_state[key]["DO"].duplicate(true)
		return
	
	var ws_p = new_state[key]["DO"]["p"]
	var wsc_p = state_collection[key]["DO"]["p"]
	
	if ws_p == wsc_p:
		new_state[key].erase("DO")
		return
	
	state_collection[key]["DO"] = new_state[key]["DO"].duplicate(true)
	state_collection[key].erase("DO")



func send_packaged_state(_packaged_state) -> void:
	assert(
		not _packaged_state.empty(),
		"SP: Packaged state can not be empty"
	)
	
	get_parent().send_packaged_state_to_server(_packaged_state)



var _frames := 0
func _has_been_20_fps() -> bool:
	_frames += 1
	if _frames%update_frame_time == 0:
		_frames = 0
		return true
	return false




