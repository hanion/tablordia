extends ScrollContainer

const tag_pl = preload("res://Systems/UMB/tag.tscn") 

export(NodePath) onready var tag_container = get_node(tag_container) as Control

func _ready(): add_tag("0")

var tag_texts_array := {} # tagtext : is_visible
func add_tag(tag:String) -> void:
	# for now
	if not tag.length() == 1 and not tag == "Chat": return
	
	var text:String = turn_tag_to_text(tag)
	
	
	if tag_texts_array.has(text): return
	
	
	var tg = tag_pl.instance() as CheckBox
	tg.text = text
	tg.connect("tag_toggled",self,"_on_tag_toggled")
	tag_container.add_child(tg,true)
	
	tag_texts_array[text] = true


func _on_tag_toggled(toggle,txt) -> void:
	tag_texts_array[txt] = not tag_texts_array[txt]
	
	
	
	var tag = turn_text_to_tag(txt)
	for msg in get_tree().get_nodes_in_group("message"):
		if msg.is_in_group(tag):
			msg.visible = toggle
	
	get_parent().scroll.scroll_to_end()





# Helper
func turn_tag_to_text(tag:String) -> String:
	var text:String
	match tag:
		"0":
			text = "Chat"
		"1":
			text = "System"
		"2":
			text = "Error"
		_:
			text = tag
			UMB.log(2,"UMB::tags","wrong tag '"+tag+"' ")
	
	return text

func turn_text_to_tag(text:String) -> String:
	var tag:String
	match text:
		"Chat":
			tag = "0"
		"System":
			tag = "1"
		"Error":
			tag = "2"
		_:
			tag = text
			UMB.log(2,"UMB::tags","wrong text '"+text+"' ")
	
	return tag

