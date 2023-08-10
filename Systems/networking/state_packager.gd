extends Node

var update_frame_time := 1
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

func collect_state(state:Dictionary) -> void:
	if state.has("pointer"):
		new_state["pointer"] = state["pointer"].duplicate(true)
	else:
		for obj_name in state.keys():
			new_state[obj_name] = state[obj_name].duplicate(true)


func _physics_process(_delta):
#	if _has_been_20_fps():
	var packaged_state = package_state()
	
	if not packaged_state: return
	
	send_packaged_state(packaged_state)




func package_state():
	if new_state.empty(): return
	
	if state_collection.empty():
		state_collection = new_state.duplicate(true)
#		return#this was commented
	
	
	for key in new_state.keys(): # key = pointer, hand1, item0, ...
		
		if not state_collection.has(key):
			state_collection[key] = new_state[key].duplicate(true)
#			STATE.set_last_state(key, state_collection[key])
			continue
		
		for subkey in new_state[key].keys(): # subkey = O, R
			if not subkey == "R" and not subkey == "O":
				assert(
					Std.has_all(state_collection,key,subkey),
					"state_collection must have subkey"
				)
			
			
			if not state_collection[key].has(subkey):
				state_collection[key][subkey] = new_state[key][subkey]
#				STATE.set_last_state(key, state_collection[key])
				continue
			
			if state_collection[key][subkey] == new_state[key][subkey]:

				# sends rotation every time
				# no matter if it changed or not
				# should solve sync problem of rotations
				# across clients
				# 
				# FIXED:
				# it only sends it 5 times,
				# then deletes it
				
				if subkey == "R":
					if state_collection[key].has("R_count"):
						state_collection[key]["R_count"] = state_collection[key]["R_count"] + 1
						if state_collection[key]["R_count"] > 5:
							state_collection[key]["R_count"] = 0
							new_state[key].erase(subkey)
							Std.erase_if_empty(new_state,key)
							continue
					else:
						state_collection[key]["R_count"] = 1
					
					continue

				new_state[key].erase(subkey)
				Std.erase_if_empty(new_state,key)
				# TEST this makes it so that it sends info every other tick
				# NO causes problems when dragging out of hand
#				state_collection[key].erase(subkey)
				continue
			
			state_collection[key][subkey] = new_state[key][subkey]
#			if key != "pointer":
#				STATE.set_last_state(key, state_collection[key])
			
			
		
	
	if new_state.empty(): return
	
	# package under our id
	var packaged_state := {
		uid:new_state.duplicate(true)
	}
	packaged_state[uid]["T"] = OS.get_system_time_msecs()
	
	return packaged_state




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




