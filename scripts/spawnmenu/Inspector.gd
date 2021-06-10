extends Control
# Inspector

var selection_name:String setget set_selection_name


onready var selection_label = $vb/SelectionName

var current_scroll
onready var BR = $vb/Scroll_BR




func set_inspector(gaem, type, naem, val) -> void:
	match gaem:
		"br":
			current_scroll = BR
			set_inspector_for_br(type,naem,val)
		_:
			current_scroll = null
			BR.visible = false
	



func set_inspector_for_br(type,naem,val) -> void:
	BR.visible = true
	BR.set_scroll_for_selection(type,naem,val)
	set_selection_name(naem)



func set_selection_name(new) -> void:
	selection_name = new
	selection_label.text = selection_name







func _on_SpawnButton_pressed():
	if current_scroll:
		current_scroll.spawn()
		get_node("../../../../..").close_menu()
