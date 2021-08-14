extends ScrollContainer

const tag_pl = preload("res://Systems/UMB/tag.tscn") 

export(NodePath) onready var tag_container = get_node(tag_container) as Control

func _ready(): add_tag("0")

var tags_array := []
func add_tag(tag:String) -> void:
	# for now
	if not tag.length() == 1 and not tag == "Chat": return
	
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
	
	
	if tags_array.has(text): return
	
	
	var tg = tag_pl.instance() as CheckBox
	tg.text = text
	tg.connect("tag_toggled",self,"_on_tag_toggled")
	tag_container.add_child(tg,true)
	
	tags_array.append(text)


func _on_tag_toggled(toggle,txt) -> void:
	var text
	match txt:
		"Chat":
			text = "0"
		"System":
			text = "1"
		"Error":
			text = "2"
	
	
	for msg in get_tree().get_nodes_in_group("message"):
		if msg.is_in_group(text):
			msg.visible = toggle
	get_parent().scroll.scroll_to_end()
