extends Spatial

onready var window = $CanvasLayer/o_screen/WindowDialog as WindowDialog
onready var tint = $CanvasLayer/o_screen/tint as Control
onready var res_dispenser = get_node("../board/dispenser")

func o(obj) -> void:
	if not obj.is_in_group("oable"): return
	get_parent().player.is_blocked_by_ui = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	window.popup()
	tint.visible = true
	




func _on_WindowDialog_popup_hide():
	window.hide()
	get_parent().player.is_blocked_by_ui = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	tint.visible = false
	


func spawn_res(res_val) -> void:
	var resource_path = res_dispenser.resource_path
	var rs = load(resource_path).instance()
	
	rs.resource_value = res_val
	rs.change_resource(res_val)
	
	
	List.cards_folder.add_child(rs)
	
	rs.set_name("resource"+str(Spawner.resource_index))
	Spawner.resource_index += 1
	
	List.paths[rs.name] = rs.get_path()
	
	
	res_dispenser.tweenit(
		rs,
		translation - Vector3(0,res_dispenser.off_y,0),
		translation + Vector3(0,res_dispenser.off_y*25,0)
		)
	

func _on_wood_pressed():
	spawn_res(1)
	_on_WindowDialog_popup_hide()


func _on_stone_pressed():
	spawn_res(2)
	_on_WindowDialog_popup_hide()


func _on_food_pressed():
	spawn_res(3)
	_on_WindowDialog_popup_hide()


func _on_steel_pressed():
	spawn_res(4)
	_on_WindowDialog_popup_hide()


func _on_gold_pressed():
	spawn_res(5)
	_on_WindowDialog_popup_hide()




