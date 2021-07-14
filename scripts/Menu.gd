extends Control

export(int,2,30) var max_peer = 8


var ip = "127.0.0.1"
var port = 4014
var Name = "0"
var color = Color.aqua

const advertiser_pl = preload("res://scenes/small/ServerAdvertiser.tscn")
const listener_pl = preload("res://scenes/small/ServerListener.tscn")

onready var primer = $margin/primer
onready var join = $margin/join
onready var host = $margin/host

onready var join_ip = $margin/join/VBox/ip
onready var join_port = $margin/join/VBox/port

onready var host_port = $margin/host/VBox/port


func _ready():
	primer.get_node("tempHBox/name").grab_focus()
	$DataSaver.load_player_data()
	
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server",self,"start_game")
	$margin/host/VBox/ip.text = (
			str(IP.get_local_addresses()).split(",",false)[0].right(1)
#			+ "," +
#			str(IP.get_local_addresses()).split(",",false)[1].right(1))
			)


func start_game():
	UMB.log(1,"Menu","Connected to server.")
#	print("\nMenu: Connected to server.\n")
	set_info()
	add_me()
	
	var game = preload("res://scenes/Main.tscn").instance()
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

func _on_primer_join_pressed():
	primer.visible = false
	join.visible = true
	
	var listener = listener_pl.instance()
	listener.connect("new_server",self,"_on_ServerListener_new_server")
	get_parent().add_child(listener)
	
	$DataSaver.save_player_data()


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
	
	ip = join_ip.text
	port = int(join_port.text)
	NetworkInterface.join(ip,port)
	
	get_node("/root/ServerListener").queue_free()
	
	$DataSaver.save_player_data()


func _on_host_host_pressed():
	
	port = int(host_port.text)
	NetworkInterface.host(port)
	
	$DataSaver.save_player_data()
	
	var ad = advertiser_pl.instance()
	get_parent().add_child(ad)
	
	start_game()


func _on_name_text_changed(new_text):
	Name = new_text
	NetworkInterface.Name = new_text


func _on_ColorPicker_color_changed(_color):
	self.color =  _color
	NetworkInterface.color = _color


func _on_ServerListener_new_server(__ip):
	NetworkInterface.join(__ip,NetworkInterface.DEFAULT_PORT)
	get_node("/root/ServerListener").queue_free()
	UMB.log(1,"Menu","Joining to "+str(__ip))
	print("                      ---- Joining to ",__ip)
