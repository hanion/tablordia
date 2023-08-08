extends Node

const DEFAULT_PORT = 4014

var uid: int
var Name: String
var color: Color

onready var server = $server
onready var client = $client
var Main

var last_joined_ip_and_port = ["127.0.0.1",4014]

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
#	if get_tree().is_network_server():
#		catch_up_the_midjoiner(id)


func catch_up_the_midjoiner(id : int) -> void:
	#UMB.logs(1,"NI","im("+str(uid)+" "+Name+") calling catchup on " + str(id) )
	client.rpc_id(id,"receive_request_collection",Spawner.request_collector.request_collection)
	client.rpc_id(id,"receive_remove_requests",Remover.remove_request_collection_of_names)
	client.rpc_id(id,"receive_alws",$server/state_processor.alws)
	
	
	yield(get_tree().create_timer(0.5),"timeout")
	client.rpc_id(id,"receive_do_collection",$client/midjoin_manager.do_collection)
	
	




func got_info_of_new_peer(id) -> void:
	var nam = List.players[id]["name"]
	var col = List.players[id]["color"].to_html()
	
	var txt = "[color=#"+col+"]"+nam+"[/color] connected"
	UMB.log(1, "Network", txt + Std.get_time())
	
	Main._spawn_player(id)
#	Main._spawn_hand(id)



func _player_disconnected(id):
	if not List.players.has(id): return
	if not List.players[id].has("name"): return
	
	var nam = List.players[id]["name"]
	var col = List.players[id]["color"] as Color
	var txt = "[color=#"+str(col.to_html())+"]" + nam + "[/color]"
	
	UMB.log(1,"Network", txt + " disconnected")
	
	
#	print("\nN: player disconnected, name:",nam,", id:",id)
#	world_state_collection.erase(id)(#)because if player accidentaly disconnects 
	# FUTURE save players info somewhere 
	List.remove_player(id)

func _on_server_disconnected() -> void:
	UMB.log(2,"Network","Server disconnected" + Std.get_time())
	
	yield(get_tree().create_timer(0.1),"timeout")
	join(last_joined_ip_and_port[0],last_joined_ip_and_port[1])
###################################INTERFACE###################################


func join(var ip: String = "127.0.0.1", var port: int = 4014) -> void:
	var _net = NetworkedMultiplayerENet.new()
	_net.create_client(ip, port)
	get_tree().set_network_peer(_net)
	
	last_joined_ip_and_port[0] = ip
	last_joined_ip_and_port[1] = port


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



func request_spawn(info) -> void:
	server.rpc_id(1,"request_spawn",info)


func send_deck_to_others(named_deck,deck_name) -> void:
	client.rpc_config("receive_deck_info",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	client.rpc_id(0,"receive_deck_info",named_deck,deck_name)



