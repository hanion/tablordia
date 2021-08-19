extends Control

export(NodePath) onready var chat = get_node(chat) as Control

const bbcodes := [
	"wave",
	"tornado",
	"rainbow",
	"shake"
	]


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
	
	var context:String
	var color
	
	# 0 == player message
	# finds player color
	if p == 0:
		var col:Color
		for pid in List.players:
			if List.players[pid]["name"] == carrier:
				col = List.players[pid]["color"] as Color
		
		color = col.to_html()
	else:
		color = group_color[p].to_html()
	
	
	var bbstart:String = "[color=#" + color + "]"
	var bbend:String = ""
	
	# Add wave if its error
	if p == 2:
		bbstart += "[wave freq=40 amp=15]"
		bbend += "[/wave]"
	
	
	
	for tx in bbcodes:
		if not txt.find("["+tx+"]") == -1:
			bbend += "[/"+tx+"]"
		
	
	
	bbend += "[/color]"
	
	context = ": " + txt
	
	# spawn richlabel text node
	var msg = chat.write(bbstart, carrier, context + bbend) as Node
	
	msg.add_to_group("message")
	
	# add msg to according group
	var tag_number := str(p)
	chat.tags.add_tag(tag_number)
	msg.add_to_group(tag_number)
	
	
	# Make msg invisible if its tag is unchecked by user
	var tag_text = chat.tags.turn_tag_to_text(tag_number)
	msg.visible = chat.tags.tag_texts_array[tag_text]
	
	
	
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


