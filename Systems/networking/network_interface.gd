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
	if not get_tree().is_network_server(): return
	
	STATE_SAVER.get_current_state_and_save()
	client.rpc_id(id, "receive_WORLD_STATE_from_server", STATE.WORLD_STATE)





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


# used by hand, change it
func send_deck_to_others(named_deck,deck_name) -> void:
	client.rpc_config("receive_deck_info",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	client.rpc_id(0,"receive_deck_info",named_deck,deck_name)







# Container Data Sync
func request_container_data(container_name : String) -> void:
	rpc_config("_request_container_data_from_server",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rpc_id(1,"_request_container_data_from_server",container_name)

remote func _request_container_data_from_server(container_name : String) -> void:
	var sender_id = get_tree().get_rpc_sender_id()
	var con = Std.get_object(container_name) as container
	if not con or not is_instance_valid(con): return
	send_container_data_to_client(sender_id, container_name, con.data_inv)

func send_container_data_to_client(sender_id,container_name,container_data:Array) -> void:
	rpc_config("receive_container_data",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rpc_id(sender_id,"receive_container_data", container_name, container_data)

remote func receive_container_data(container_name:String, container_data:Array) -> void:
	var con = Std.get_object(container_name) as container
	if not con or not is_instance_valid(con): return
	
	con.data_inv = container_data
	con.order_env()
#	for data in container_data:
#		con.add_data_to_container(data)




