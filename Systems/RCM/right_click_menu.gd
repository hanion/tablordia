extends Control

onready var popup = $PopupMenu

onready var wa = $WriteAmountPop
onready var wa_per0 = $WriteAmountPop/vbc/period
onready var wa_per1 = $WriteAmountPop/vbc/period2
onready var wa_per2 = $WriteAmountPop/vbc/period3
onready var wa_label0 = $WriteAmountPop/vbc/period/Label
onready var wa_label1 = $WriteAmountPop/vbc/period2/Label
onready var wa_label2 = $WriteAmountPop/vbc/period3/Label

onready var hand_settings = $HandSettings

var player
var current_object = null
var is_popup_open := false


func right_clicked(to:Spatial) -> void:
	if is_popup_open: return
#	player = get_node("/root/Main/player")
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
	
	Std.is_blocked_by_ui = true



func close_popup():
	is_popup_open = false
	Std.is_blocked_by_ui = false
	
	player.cast_ray()
	player.move_pointer()
	



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



func open_wa(sigto:Dictionary, title, l0="",l1="",l2="") -> ConfirmationDialog:
	wa.window_title = title
	
	if not l0 == "":
		wa_per0.visible = true
		wa_label0.text = l0
		
	
	if not l1 == "":
		wa_per1.visible = true
		wa_label1.text = l1
	
	if not l2 == "":
		wa_per2.visible = true
		wa_label2.text = l2
	
	
	wa.set_as_minsize()
	wa.popup()
	
	
	if not wa.is_connected("confirmed",sigto["target"],sigto["method"]):
		wa.connect("confirmed",sigto["target"],sigto["method"])
	
	
#	yield(get_tree().create_timer(1),"timeout")
	
	Std.is_blocked_by_ui = true
	wa_per0.get_node("LineEdit").grab_focus()
	
	return wa

func close_wa() -> void:
	wa.visible = false
	Std.is_blocked_by_ui = false



func open_hand_settings(target,method) -> AcceptDialog:
	hand_settings.popup()
	
	if not hand_settings.is_connected("confirmed",target,method):
		hand_settings.connect("confirmed",target,method)
	
	Std.is_blocked_by_ui = true
	
	return hand_settings

func close_hand_settings() -> void:
	hand_settings.visible = false
	Std.is_blocked_by_ui = false






func _on_PopupMenu_popup_hide():
	if is_popup_open:
		close_popup()


func _on_PopupMenu_index_pressed(index):
	close_popup()
	clicked_at(index)


