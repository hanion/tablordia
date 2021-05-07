extends Node

onready var state_packager = $state_packager

####################################CLIENT#####################################


func collect_state(state):
	if List.players.size() == 0: return # if im testing the game
#	if List.players.size() == 1: return # if player is alone
	assert(
		not state.empty(),
		"NI: Can not send empty state"
	)
	state_packager.collect_state(state)



# called from state_packager
func send_packaged_state_to_server(packaged_state):
	get_parent().server.rpc_id(1,"receive_state_from_client",packaged_state)


# called from server
remote func receive_world_state_from_server(world_state):
	assert(
		not world_state.empty(),
		"N:CLIENT: !!! Received world state is empty"
	)
#	print("\nreceived--------------------\n",world_state)
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
	
	print("\nc: player connected",
	", name: ",you["name"], 
	", id: ",sender_id,
	", color:",you["color"]
	)
	
	List.add_player(sender_id, you)
	NetworkInterface.got_info_of_new_peer(sender_id)





remote func receive_invs(res_inv,itm_inv) -> void:
	NetworkInterface.Main.resource_dispenser.set_received_inv(res_inv)
	NetworkInterface.Main.item_dispenser.set_received_inv(itm_inv)


remote func receive_requested_spawn(_ty,_va,_am) -> void:
	Spawner.receive_requested_spawn(_ty,_va,_am)
