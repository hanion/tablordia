extends Control

export(int,2,30) var max_peer = 8


var ip = "127.0.0.1"
var port = 4014
var Name = "0"
var color = Color.red


onready var primer = $margin/primer
onready var join = $margin/join
onready var host = $margin/host

onready var join_ip = $margin/join/VBox/ip
onready var join_port = $margin/join/VBox/port

onready var host_port = $margin/host/VBox/port


func _ready():
	primer.get_node("tempHBox/name").grab_focus()
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server",self,"start_game")
	$margin/host/VBox/ip.text = (
			str(IP.get_local_addresses()).split(",",false)[0].right(1)
#			+ "," +
#			str(IP.get_local_addresses()).split(",",false)[1].right(1))
			)


func start_game():
	print("\nMenu: Connected to server.\n")
	set_info()
	add_me()
	# FIXME read Notes
#	yield(get_tree().create_timer(5),"timeout")
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
	print("Mn: adding myself to the List")
	var host_dict = {
		"name":Name,
		"color":color
		}
	List.add_player(NetworkInterface.uid,host_dict)


####################################SIGNALS####################################

func _on_primer_join_pressed():
	primer.visible = false
	join.visible = true


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


func _on_host_host_pressed():
	
	port = int(host_port.text)
	NetworkInterface.host(port)
	
	start_game()


func _on_name_text_changed(new_text):
	Name = new_text
	NetworkInterface.Name = new_text


func _on_ColorPicker_color_changed(_color):
	self.color =  _color
	NetworkInterface.color = _color
