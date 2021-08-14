extends Node

signal new_server(ip)

var socket_udp = PacketPeerUDP.new()
var listen_port = NetworkInterface.DEFAULT_PORT

func _ready():
	var er = socket_udp.listen(listen_port)
	if er == OK:
		print("LAN Server Listener: " + str(listen_port))
	else:
		print("LAN Server Listener: Error listening on port: " + str(listen_port),er)

func _process(_delta):
	if socket_udp.get_available_packet_count() > 0:
		var server_ip = socket_udp.get_packet_ip()
		var server_port = socket_udp.get_packet_port()
		var _packet = socket_udp.get_packet()
		
		if server_ip != '' and server_port > 0:
			var ip = server_ip
			
			print("SL: Found server, ip:",socket_udp.get_packet_ip())
			emit_signal("new_server", ip)
			

func _exit_tree():
	socket_udp.close()
