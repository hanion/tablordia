extends VBoxContainer

const msg_pl = preload("res://Systems/UMB/msg.tscn")


export(NodePath) onready var ledit = get_node(ledit) as LineEdit

export(NodePath) onready var scroll = get_node(scroll) as ScrollContainer
export(NodePath) onready var msg_container = get_node(msg_container) as Control

export(NodePath) onready var tags = get_node(tags) as ScrollContainer

var last_carrier := ""
var last_tag := -1
var last_msg : RichTextLabel
func write(bbstart:String, carrier:String, bbend:String, tag:int) -> Node:
	UMB.chat_closed()
	UMB.reset_alpha()
	
	if last_carrier == carrier and last_tag == tag:
		var ms = "[color=#00ffffff][i]"+carrier+"[/i][/color]" # transparent name
		
		last_msg.bbcode_text += "\n" + ms + bbstart + bbend
		
		if carrier == "Settings":
			last_msg.bbcode_text = bbstart+carrier+bbend
		
		return last_msg
	
	var msg = msg_pl.instance() as RichTextLabel
	
	var text = bbstart+carrier+bbend
	msg.bbcode_text = text
	
	msg_container.add_child(msg)
	
	
	
	
	last_carrier = carrier
	last_tag = tag
	last_msg = msg
	return msg


func _on_input_field_text_entered(txt:String) -> void:
	UMB.chat_closed()
	
	if txt.begins_with('/'):
		CMD.parse_command(txt)
		return
	
	if txt == '': return
	if txt.length() > 50: return
	
	
	UMB.logs(0,NetworkInterface.Name,txt)



