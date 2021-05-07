extends Node

var uid: int
var Name: String
var color: Color

onready var server = $server
onready var client = $client
var Main


####################################SIGNALS####################################


func _ready():
	client.rpc_config("notify_existing_player_about_me",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	client.rpc_config("receive_world_state_from_server",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	
#	server.rpc_config("request_invs",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	client.rpc_config("receive_invs",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	client.rpc_config("receive_requested_spawn",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self,"_player_connected")
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")


func _player_connected(id):
	List.add_player(id)
	client.give_my_info_to(id)

func got_info_of_new_peer(id) -> void:
	Main._spawn_player(id)
	Main._spawn_hand(id)



func _player_disconnected(id):
	print("\nN: player disconnected, name:",List.players[id]["name"],", id:",id)
#	world_state_collection.erase(id)(#)because if player accidentaly disconnects 
	# TODO save players info somewhere 
	List.remove_player(id)

###################################INTERFACE###################################


func join(var ip: String = "127.0.0.1", var port: int = 4014) -> void:
	var _net = NetworkedMultiplayerENet.new()
	_net.create_client(ip, port)
	get_tree().set_network_peer(_net)


func host(var port: int = 4014, var max_peer: int = 4) -> void:
	var _net = NetworkedMultiplayerENet.new()
	_net.create_server(port, max_peer)
	get_tree().set_network_peer(_net)


func collect_state(state):
	client.collect_state(state)



func send_received_world_state_to_main(world_state):
	Main.process_received_world_state(world_state)



func request_envs() -> void:
	yield(get_tree().create_timer(1),"timeout")
	server.rpc_id(1,"request_invs")



func request_spawn(_type,_value,_amount) -> void:
	server.rpc_id(1,"request_spawn",_type,_value,_amount)

