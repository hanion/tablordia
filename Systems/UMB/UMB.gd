extends Control

export(NodePath) onready var chat = get_node(chat) as Control
export(NodePath) onready var out0 = get_node(out0) as Control
export(NodePath) onready var out1 = get_node(out1) as Control

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
	
	
	
	
	
	var found_bbs = {}
	for tx in bbcodes:
		var prefix = "["+tx
		if not (txt.find(prefix) == -1):
			found_bbs[tx] = txt.find(prefix)
	
	
	while not found_bbs.empty():
		var biggest_tx: String
		var bigness = -2
		for tx in found_bbs.keys():
			if found_bbs[tx] > bigness:
				biggest_tx = tx
				bigness = found_bbs[tx]
		
		bbend += "[/"+biggest_tx+"]"
		found_bbs.erase(biggest_tx)
	
	
	
	
	
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
	out0.visible = false
	out1.visible = false
	chat.ledit.visible = true

######################
####### auto hide chat
var auto_hide_chat := true
var auto_hide_chat_time := 3
var __chat_alpha_process = 0
func reset_alpha() -> void:
	__chat_alpha_process = 1
	for _i in range(6):
		if __chat_alpha_process == 2: return
		yield(get_tree().create_timer(0.01),"timeout")
		modulate.a = lerp(modulate.a,SettingsUI.chat_alpha,0.2)
	modulate.a = SettingsUI.chat_alpha
	__chat_alpha_process = 0

func fade() -> void:
	if not auto_hide_chat: return
	if __chat_alpha_process == 1: return
	__chat_alpha_process = 2
	yield(get_tree().create_timer(auto_hide_chat_time),"timeout")
	if not auto_hide_chat: return
	if __chat_alpha_process == 1: return
	
	for _i in range(100):
		if __chat_alpha_process == 1: return
		yield(get_tree().create_timer(0.01),"timeout")
		modulate.a = lerp(modulate.a,-1,0.01)
	__chat_alpha_process = 0
####### /auto hide chat
######################


func _on_chat_mouse_entered():
	chat_opened()

func chat_opened() -> void:
	Std.is_blocked_by_ui = true
	auto_hide_chat = false
	chat.ledit.grab_focus()
	chat.scroll.scroll_to_end()
	
	chat.tags.tag_container.visible = true
	
	var vs = chat.scroll.get_v_scrollbar() as VScrollBar
	vs.modulate = Color.white
	reset_alpha()


func chat_closed() -> void:
	Std.is_blocked_by_ui = false
	auto_hide_chat = SettingsUI.auto_hide_chat
	remove_focus()
	chat.scroll.scroll_to_end()
	
	chat.tags.tag_container.visible = false
	
	var vs = chat.scroll.get_v_scrollbar() as VScrollBar
	vs.modulate = Color.transparent
	
	chat.ledit.text = ""
	fade()


