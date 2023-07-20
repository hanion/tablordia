extends Node


#	var info  = {
#		"type":type,
#		"name":name,
#		"amount":amount,
#		"value":val,
#		"owner_id":hand_owner_id,
#		"in_deck":deck name,
#		"in_dispenser":self.name,
#		"translation":spawn translation
#		}

#var request_collection = {
#	"request_index":info
#}

# called from server->client when joined server
func process_spawn_requests(request_collection:Dictionary) -> void:
	if request_collection.empty(): return
	if get_tree().is_network_server(): return
	
	
	for request_index in request_collection.keys():
		var info = request_collection[request_index]
		
		# already spawned
		# probably just a drop, midgame 
		if List.paths.has(info["name"]):
			continue
		
		# calling this so it is local
		# only called from joining client to itself
		Spawner.receive_requested_spawn(info)



var do_collection = {}

#"dragged_name" = {
#	"d":dragged_name,
#	"o":over_name,
#	"p":psoition,
#	"T_do":time of do
#}

#	var do_state = {
#		"d":d.name,
#		"o":o.name,
#		"p":p
#		}

func collect_do(do:Dictionary) -> void:
	
	var dragged_name = do["d"]
	
	if not do_collection.has(dragged_name):
		do_collection[dragged_name] = do.duplicate(true)
		return
	
	
	assert(do.has("T_do"), "do must have T_do")
	assert(do_collection[dragged_name].has("T_do"), "do_collection must have T_do")
	if not do.has("T_do"): return
	if not do_collection[dragged_name].has("T_do"): return
	
	
	if do_collection[dragged_name]["T_do"] < do["T_do"]:
		do_collection[dragged_name] = do.duplicate(true)
		return
	











