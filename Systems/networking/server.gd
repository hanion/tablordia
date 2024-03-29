extends Node

var world_state_up := {}

####################################SERVER#####################################
func _ready():
	rpc_config("receive_state_from_client",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rpc_config("receive_do_from_client",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	
	rpc_config("request_spawn",MultiplayerAPI.RPC_MODE_REMOTESYNC)

remote func receive_state_from_client(state: Dictionary) -> void:
	assert(
		not state.empty(),
		"State Cant BE EMPTY"
		)
	
#	print("  s: received packed state from client ",state)
	world_state_up = state.duplicate(true)


""" DO """
remote func receive_do_from_client(do:Dictionary) -> void:
	assert(
		not do.empty(),
		"DO State Cant BE EMPTY"
		)
	
#	print("  s: received DO state from client ",do)
	NetworkInterface.client.rpc("receive_do_from_server",do)
""" /DO """




# called from state_processor, going to the client
func send_processed_world_state_to_client(world_state):
	assert(
		not world_state.empty(),
		"N:SERVER: !!! Cant send empty world state to client"
	)
#	print("  s: sending world state to client")
	get_parent().client.rpc_unreliable_id(0,"receive_world_state_from_server",world_state)






remote func request_spawn(info) -> void:
	# commented: when using a dedicated server, peers cant spawn
#	var sender_id = get_tree().get_rpc_sender_id()
#	if not sender_id == 1: return
	NetworkInterface.client.rpc("receive_requested_spawn",info)
