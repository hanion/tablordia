extends Node


var world_state := {}
var world_state_collection := {}
var alws := {} # all_latest_world_states
var update_frame_time = 1

func _physics_process(_delta):
	if not get_tree().has_network_peer(): return
	# if we are not the host, delete processor
	if not get_tree().is_network_server(): 
		queue_free()
		print("State Processor: Aight, imma head out")
		return
	
	
	if _has_been_20_fps():
#		print("**sending do _pp")
		process_world_state()

func process_world_state():
	if get_parent().world_state_up.empty(): return
	
	world_state = get_parent().world_state_up.duplicate(true)
	
	
	var going_world_state = world_state
	if not going_world_state: return
	
	# TMP What if we trust client and not process it
#	print("  s:sp: processed state   ",world_state)
	get_parent().world_state_up.clear()
	
	if world_state.empty(): return
	
	
	###########################################################################
	# Anti cheat
	# checks
	save_state_to_collection(world_state)
	going_world_state["T"] = OS.get_system_time_msecs()
	get_parent().send_processed_world_state_to_client(going_world_state)
	###########################################################################



func save_state_to_collection(state):
	if state.empty(): return
	
	for sid in state.keys():
		for key in state[sid].keys():
			if key == "T":
				continue
			elif key == "pointer":
				continue
	#			update_pointer(sid,istate["pointer"],istate["T"])
			else:
				update_obj(key, state[sid][key], state[sid]["T"])
			


func update_obj(obn, obs, time) -> void:
	if not alws.has(obn):
		alws[obn] = obs.duplicate(true)
		alws[obn]["T"] = time
	
	assert(alws[obn].has("T"), "no")
	
	if alws[obn]["T"] < time:
		alws[obn] = obs.duplicate(true)
		alws[obn]["T"] = time
	
#	print("obn:",obn,"\nobs:",obs,"\n")









var _frames := 0
func _has_been_20_fps() -> bool:
	_frames += 1
	if _frames%update_frame_time == 0:
		_frames = 0
		return true
	return false
