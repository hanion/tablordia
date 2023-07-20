extends Node

onready var state_packager = $state_packager

func _ready():
	rpc_config("notify_existing_player_about_me",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rpc_config("receive_world_state_from_server",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rpc_config("receive_do_from_server",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	
	rpc_config("receive_br_info",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rpc_config("receive_requested_spawn",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rpc_config("receive_alws",MultiplayerAPI.RPC_MODE_REMOTESYNC)

####################################CLIENT#####################################

func collect_state(state):
	if List.players.size() == 0: return # if im testing the game
#	if List.players.size() == 1: return # if player is alone
	assert(
		not state.empty(),
		"NI: Can not send empty state"
		)
	
#	if not state.has("pointer"):
#		print("c::cs: ",state)
	state_packager.collect_state(state)


""" DO """
func send_do_state(do_state) -> void:
	if List.players.size() == 0: return # if im testing the game
#	if List.players.size() == 1: return # if player is alone
	assert(
		not do_state.empty(),
		"NI: Can not send empty do state"
		)
	
	do_state["T_do"] = OS.get_system_time_msecs()
	NetworkInterface.server.rpc_id(1,"receive_do_from_client",do_state)
remote func receive_do_from_server(do:Dictionary) -> void:
	assert(
		not do.empty(),
		"N:CLIENT: !!! Received DO is empty"
		)
	NetworkInterface.send_received_do_to_main(do)
""" /DO """




# called from state_packager
func send_packaged_state_to_server(packaged_state):
#	print(" c: sending packed state")
	if not get_tree().network_peer: return
	
	if get_tree().network_peer.get_connection_status() == 2:
		NetworkInterface.server.rpc_unreliable_id(1,"receive_state_from_client",packaged_state)


# called from server
remote func receive_world_state_from_server(world_state):
	assert(
		not world_state.empty(),
		"N:CLIENT: !!! Received world state is empty"
		)
	NetworkInterface.send_received_world_state_to_main(world_state)






func give_my_info_to(to_id) -> void:
	var my_name = NetworkInterface.Name
	var my_color = NetworkInterface.color
	
	
	
	var me = {
		"name": my_name,
		"color": my_color,
		}
	
	rpc_id(to_id,"notify_existing_player_about_me",me)


remote func notify_existing_player_about_me(var you: Dictionary) -> void:
	var sender_id = get_tree().get_rpc_sender_id()
	
	print("\n",
	"c: ",
	you["name"]," connected",", id: ",sender_id,", color:",you["color"])
	
	List.add_player(sender_id, you)
	NetworkInterface.got_info_of_new_peer(sender_id)




remote func receive_br_info(res,itm) -> void:
	NetworkInterface.Main.br.receive_br_info(res,itm)

remote func receive_requested_spawn(info) -> void:
	Spawner.receive_requested_spawn(info)


remote func receive_request_collection(request_collection:Dictionary) -> void:
	$midjoin_manager.process_spawn_requests(request_collection)

remote func receive_alws(alws) -> void:
	$alws_processor.process_alws(alws)

remote func receive_deck_info(named_deck,deck_name) -> void:
	if not get_tree().get_rpc_sender_id() == 1: return
	if get_tree().get_network_unique_id() == 1: return
	Std.get_object(deck_name).receive_deck_from_server(named_deck)

remote func receive_invs(res_inv, itm_inv) -> void:
	if NetworkInterface.Main.br:
		NetworkInterface.Main.br.receive_br_info(res_inv, itm_inv)
		print("called it ", res_inv, itm_inv)



remote func receive_do_collection(do_collection:Dictionary) -> void:
	for do_obj in do_collection:
		NetworkInterface.send_received_do_to_main(do_collection[do_obj])



