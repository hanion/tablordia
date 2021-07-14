extends Control

export(NodePath) onready var chat = get_node(chat) as Control


const group_color = [# p
	Color.white,     # 0 = chat message
	Color.slategray, # 1 = system message
	Color.lightcoral # 2 = error
	]


func logs(p:int, carrier:String, txt:String, extra_color:=Color.white) ->  void:
	rpc_config("_logs_to_log",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rpc("_logs_to_log",p,carrier,txt,extra_color)
remote func _logs_to_log(_p, _carrier, _txt,_extra_color) ->  void:
	UMB.log(_p,_carrier,_txt,_extra_color)


func log(p:int, carrier:String, txt:String, extra_color:=Color.white) ->  void:
	
	var bbtext:String
	var color
	if p == 0:
		color = extra_color.to_html()
	else:
		color = group_color[p].to_html()
	
	
	var bbstart:String = "[color=#" + color + "]"
	var bbend := ""
	
	if p == 2:
		bbstart += "[wave freq=40 amp=15]"
		bbend += "[wave]"
	
	bbtext = bbstart + (carrier + ": " + txt) + bbend
	
	
	var msg = chat.write(bbtext) as Node
	
	msg.add_to_group("message")
	
	
	
	chat.tags.add_tag(str(p))
	msg.add_to_group(str(p))
	
#	msg.add_to_group(carrier)
#	chat.tags.add_tag(carrier)
	






func _unhandled_key_input(event):
	if event.is_action_pressed("chat"):
		chat_opened()



func _on_input_field_focus_exited():
	chat_closed()

func remove_focus() -> void:
	chat.ledit.visible = false
	$out.visible = false
	chat.ledit.visible = true




func _on_chat_mouse_entered():
	chat_opened()

func chat_opened() -> void:
	chat.ledit.grab_focus()
	chat.scroll.scroll_to_end()
	
	chat.tags.tag_container.visible = true
	
	var vs = chat.scroll.get_v_scrollbar() as VScrollBar
	vs.modulate = Color.white


func chat_closed() -> void:
	remove_focus()
	chat.scroll.scroll_to_end()
	
	chat.tags.tag_container.visible = false
	
	var vs = chat.scroll.get_v_scrollbar() as VScrollBar
	vs.modulate = Color.transparent
	
	chat.ledit.text = ""


