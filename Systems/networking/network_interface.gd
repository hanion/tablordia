extends Node

const DEFAULT_PORT = 4014

var uid: int
var Name: String
var color: Color

onready var server = $server
onready var client = $client
var Main


####################################SIGNALS####################################


func _ready():
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self,"_player_connected")
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected",self,"_on_server_disconnected")


func _player_connected(id):
	List.add_player(id)
	client.give_my_info_to(id)
	if get_tree().is_network_server():
		client.rpc_id(id,"receive_alws",$server/state_processor.alws)

func got_info_of_new_peer(id) -> void:
	var nam = List.players[id]["name"]
	var col = List.players[id]["color"].to_html()
	
	var txt = "[color=#"+col+"]"+nam+"[/color] connected"
	UMB.log(1, "Network", txt)
	
	Main._spawn_player(id)
#	Main._spawn_hand(id)



func _player_disconnected(id):
	var nam = List.players[id]["name"]
	var col = List.players[id]["color"] as Color
	var txt = "[color=#"+str(col.to_html())+"]" + nam + "[/color]"
	
	UMB.log(1,"Network", txt + " disconnected")
	
	
#	print("\nN: player disconnected, name:",nam,", id:",id)
#	world_state_collection.erase(id)(#)because if player accidentaly disconnects 
	# FUTURE save players info somewhere 
	List.remove_player(id)

func _on_server_disconnected() -> void:
	UMB.log(2,"Network","Server disconnected")
	
###################################INTERFACE###################################


func join(var ip: String = "127.0.0.1", var port: int = 4014) -> void:
	var _net = NetworkedMultiplayerENet.new()
	_net.create_client(ip, port)
	get_tree().set_network_peer(_net)


func host(var port: int = 4014, var max_peer: int = 16) -> void:
	var _net = NetworkedMultiplayerENet.new()
	_net.create_server(port, max_peer)
	get_tree().set_network_peer(_net)


func collect_state(state:Dictionary) -> void:
	client.collect_state(state)



""" DO """
func send_do_state(do_state:Dictionary) -> void:
	client.send_do_state(do_state)
func send_received_do_to_main(do) -> void:
	Main.process_received_do(do)
""" /DO """



func send_received_world_state_to_main(world_state):
	Main.process_received_world_state(world_state)



func send_br_info(res_env,itm_env) -> void:
	server.rpc_id(1,"receive_br_info",res_env,itm_env)



func request_spawn(info) -> void:
	server.rpc_id(1,"request_spawn",info)


func send_deck_to_others(named_deck,deck_name) -> void:
	client.rpc_config("receive_deck_info",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	client.rpc_id(0,"receive_deck_info",named_deck,deck_name)



