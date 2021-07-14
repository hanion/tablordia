extends VBoxContainer

const msg_pl = preload("res://scenes/UMB/msg.tscn")


export(NodePath) onready var ledit = get_node(ledit) as LineEdit

export(NodePath) onready var scroll = get_node(scroll) as ScrollContainer
export(NodePath) onready var msg_container = get_node(msg_container) as Control

export(NodePath) onready var tags = get_node(tags) as ScrollContainer


func write(txt:String) -> Node:
	
	var msg = msg_pl.instance() as RichTextLabel
	
	msg.bbcode_text = txt
	
	msg_container.add_child(msg)
	
	UMB.chat_closed()
	
	return msg


func _on_input_field_text_entered(txt:String) -> void:
	UMB.chat_closed()
	
	if txt.begins_with('/'):
		
		return
	
	if txt == '': return
	if txt.length() > 50: return
	
	
	UMB.logs(0,NetworkInterface.Name,txt,NetworkInterface.color)




