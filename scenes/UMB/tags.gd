extends ScrollContainer

const tag_pl = preload("res://scenes/UMB/tag.tscn") 

export(NodePath) onready var tag_container = get_node(tag_container) as Control

func _ready(): add_tag("Chat")

var tags_array := []
func add_tag(tag:String) -> void:
	if tags_array.has(tag): return
	
	# for now i don't want to mask player messages
	for pid in List.players: 
		if tag == List.players[pid]["name"]: return
	
	# for now
	if not tag.length() == 1:
		if not tag == "Chat":
			return
	
	
	var tg = tag_pl.instance() as CheckBox
	tg.text = tag
	tg.connect("tag_toggled",self,"_on_tag_toggled")
	tag_container.add_child(tg,true)
	
	tags_array.append(tag)


func _on_tag_toggled(toggle,txt) -> void:
	for msg in get_tree().get_nodes_in_group("message"):
		if msg.is_in_group(txt):
			msg.visible = toggle
	get_parent().scroll.scroll_to_end()
