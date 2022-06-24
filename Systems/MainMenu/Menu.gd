extends Control

export(int,2,30) var max_peer = 8


var ip = "127.0.0.1"
var port = 4014
var Name = "0"
var color = Color.aqua

const advertiser_pl = preload("res://Systems/networking/ServerAdvertiser.tscn")
const listener_pl = preload("res://Systems/networking/ServerListener.tscn")

onready var primer = $margin/primer
onready var join = $margin/join
onready var host = $margin/host

onready var join_ip = $margin/join/VBox/ip
onready var join_port = $margin/join/VBox/port

onready var host_port = $margin/host/VBox/port
onready var lineip = $hbmenu/vb/vb2host/lineip


func _ready():
	$DataSaver.load_player_data()
	
	# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server",self,"start_game")
	lineip.text = (str(IP.get_local_addresses()).split(",",false)[0].right(1))
#			+ "," +
#			str(IP.get_local_addresses()).split(",",false)[1].right(1))


func start_game():
	UMB.log(1,"Menu","Connected to server.")
	set_info()
	add_me()
	
	var game = preload("res://Systems/MainMenu/Main.tscn").instance()
	get_parent().add_child(game)
	
	queue_free()


func set_info():
	var uid = get_tree().get_network_unique_id()
	NetworkInterface.Name = Name
	NetworkInterface.color = color
	NetworkInterface.uid = uid
	NetworkInterface.client.get_node("state_packager").uid = uid


func add_me():
#	UMB.log(1,"Main","Prepared List")
#	print("Mn: adding myself to the List")
	var host_dict = {
		"name":Name,
		"color":color
		}
	List.add_player(NetworkInterface.uid,host_dict)


####################################SIGNALS####################################
func deploy_server_listener() -> void:
	if get_node("/root").has_node("ServerListener"):
		print("!!!Menu: there is already a Server Listener")
		return
	
	var listener = listener_pl.instance()
	listener.connect("new_server",self,"_on_ServerListener_new_server")
	get_parent().add_child(listener)
func destroy_server_listener() -> void:
	if not get_node("/root").has_node("ServerListener"):
		print("!!!Menu: no Server Listener to destroy")
		return
	
	get_node("/root/ServerListener").queue_free()
	print("Menu: destroyed Server Listener")



func deploy_server_advertiser() -> void:
	var ad = advertiser_pl.instance()
	get_parent().add_child(ad)

func save_player_data() -> void:
	$DataSaver.save_player_data()


func Join(var _ip, var _port):
	ip = _ip
	port = int(_port)
	NetworkInterface.join(ip,port)
	
	destroy_server_listener()
	save_player_data()


func Host(var _port):
	port = int(_port)
	NetworkInterface.host(port,max_peer)
	
	save_player_data()
	destroy_server_listener()
	deploy_server_advertiser()
	start_game()


func _on_ServerListener_new_server(__ip):
	NetworkInterface.join(__ip,NetworkInterface.DEFAULT_PORT)
	destroy_server_listener()
	UMB.log(1,"Menu","Joining to "+str(__ip))
	print("                      ---- Joining to ",__ip)









#################################### OLD UI ####################################

func _on_primer_join_pressed():
	primer.visible = false
	join.visible = true
	deploy_server_listener()


func _on_primer_host_pressed():
	primer.visible = false
	host.visible = true


func _on_join_cancel_pressed():
	primer.visible = true
	join.visible = false


func _on_host_cancel_pressed():
	primer.visible = true
	host.visible = false




func _on_join_join_pressed():
	Join(join_ip.text,join_port.text)



func _on_host_host_pressed():
	Host(host_port.text)

