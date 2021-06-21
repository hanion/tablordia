extends Control
# Inspector

var selection_name:String setget set_selection_name


onready var selection_label = $vb/SelectionName

var current_scroll
onready var BR = $vb/Scroll_BR
onready var Boards = $vb/Scroll_Boards




func set_inspector(gaem, type, naem, val) -> void:
	BR.visible = false
	Boards.visible = false
	
	match gaem:
		"br":
			current_scroll = BR
			BR.set_scroll_for_selection(type,naem,val)
			BR.visible = true
		"Board":
			current_scroll = Boards
			Boards.set_scroll_for_selection(type,naem,val)
			Boards.visible = true
		_:
			current_scroll = null
			return
	
	set_selection_name(naem)



func set_selection_name(new) -> void:
	selection_name = new
	selection_label.text = selection_name







func _on_SpawnButton_pressed():
	if current_scroll:
		current_scroll.spawn()
		get_node("../../../../..").close_menu()
