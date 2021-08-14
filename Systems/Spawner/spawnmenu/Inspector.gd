extends Control
# Inspector

var selection_name:String setget set_selection_name


onready var selection_label = $vb/SelectionName

onready var scroll = $vb/vsc/Scroll_Boards




func set_inspector(info) -> void:
	scroll.set_scroll_for_selection(info)
	
	if info.has("inspector_text"):
		set_selection_name(info["inspector_text"])
	else:
		set_selection_name(info["name"])



func set_selection_name(new) -> void:
	selection_name = new
	selection_label.text = selection_name







func _on_SpawnButton_pressed():
	scroll.spawn()
	get_node("../../../../..").close_menu()
