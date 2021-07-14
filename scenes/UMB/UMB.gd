extends Control

export(NodePath) onready var chat = get_node(chat) as Control



const group_color = [# p
	Color.white,     # 0 = chat message
	Color.slategray, # 1 = system message
	Color.lightcoral # 2 = error
	]


func logs(p:int, carrier:String, txt:String) ->  void:
	rpc_config("_logs_to_log",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rpc("_logs_to_log",p,carrier,txt)
remote func _logs_to_log(_p, _carrier, _txt) ->  void:
	UMB.log(_p,_carrier,_txt)


func log(p:int, carrier:String, txt:String) ->  void:
	
	var bbtext:String
	
	var bbstart:String = "[color=#" + group_color[p].to_html() + "]"
	var bbend := "[/color]"
	
	bbtext = bbstart + (carrier + ": " + txt) + bbend
	
	
	var msg = chat.write(bbtext) as Node
	
	msg.add_to_group("message")
	msg.add_to_group(str(p))
	msg.add_to_group(carrier)




