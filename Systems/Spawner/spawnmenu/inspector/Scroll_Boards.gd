extends ScrollContainer
# Scroll_Boards

var amount:int = 1
var type:String
var naem:String
var owner_id:int
var val:int
var val_second:int = 0
var others_can_touch:bool = true

func spawn() -> void:
	var info  = {
		"type":type,
		"name":naem,
		"amount":amount,
		"owner_id":owner_id,
		"value":val,
		"value_second":val_second,
		"others_can_touch":others_can_touch
		}
	Spawner.request_spawn(info)
	get_node("vb/amount/SpinBox").value = 1



func set_scroll_for_selection(info) -> void:
	type = info["type"]
	naem = info["name"]
	
	if info.has("value"):
		val = info["value"]
	if info.has("value_second"):
		val_second = info["value_second"]
	
	$vb/owner.visible  =  (naem == "Hand")
	$vb/oct.visible  =  (naem == "Hand")
	$vb/uno_team.visible  =  (naem == "Uno Card")
	



func _on_amount_amount_changed(am):
	amount = am



func _on_owner_on_owner_changed(ownerid):
	owner_id = ownerid


func _on_uno_team_color_changed(a):
	val_second = a


func _on_oct_oct_checked(toggle) -> void:
	others_can_touch = toggle
