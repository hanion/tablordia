extends Control

onready var popup = $PopupMenu
var player
var current_object = null
var is_popup_open := false

func right_clicked(to:Spatial) -> void:
	if is_popup_open: return
	player = get_node("/root/Main/player")
	if not to.is_in_group("has_rcm"): 
		if to.get_parent().is_in_group("has_rcm"):
			to = to.get_parent()
		else:
			return
	
	to.prepare_rcm(popup)
	current_object = to
	
	if popup.get_item_count() > 0:
		popup.add_separator("")
	popup.add_item("Cancel",404)
	open_popup()


func open_popup():
	is_popup_open = true
	var mpos = get_viewport().get_mouse_position()
	popup.rect_position = mpos
	popup.set_as_minsize()
	popup.popup()
	
	player.is_blocked_by_ui = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)



func close_popup():
	is_popup_open = false
	player.cast_ray()
	player.move_pointer()
	
	player.is_blocked_by_ui = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)



func clicked_at(index) -> void:
	var item_id = popup.get_item_id(index)
	var item_text = popup.get_item_text(index)
	
	prints("     RCM: Clicked at:: idx:",index,"id:",item_id," str:",item_text)
	
	if item_id == 404: return
	
	
	current_object.rpc_config("rcms",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	current_object.rpc("rcms",item_id,index,item_text)



func get_a_submenu(_popup,nam) -> PopupMenu:
	var submenu = null
	for child in _popup.get_children():
		if child is PopupMenu:
			if child.name == nam:
				submenu = child
				break
	
	if not submenu:
		submenu = PopupMenu.new()
		_popup.add_child(submenu)
		submenu.set_name(nam)
	
	submenu.clear()
	return submenu



func _on_PopupMenu_popup_hide():
	close_popup()


func _on_PopupMenu_index_pressed(index):
	close_popup()
	clicked_at(index)


