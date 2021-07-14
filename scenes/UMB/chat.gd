extends VBoxContainer

const msg_pl = preload("res://scenes/UMB/msg.tscn") 


export(NodePath) onready var chat_log = get_node(chat_log) as RichTextLabel

export(NodePath) onready var label = get_node(label) as Label
export(NodePath) onready var ledit = get_node(ledit) as LineEdit

export(NodePath) onready var scroll = get_node(scroll) as ScrollContainer
export(NodePath) onready var msg_container = get_node(msg_container) as Control

func write(txt:String) -> Node:
	
	var msg = msg_pl.instance() as RichTextLabel
	
	msg.bbcode_text = txt
	
	msg_container.add_child(msg)
	
	scroll.scroll_to_end()
	
	return msg


func _on_input_field_text_entered(txt:String) -> void:
	ledit.text = ""
	
	if txt.begins_with('/'):
		
		return
	
	if txt == '': return
	
	
	UMB.logs(0,NetworkInterface.Name,txt)
	
	
