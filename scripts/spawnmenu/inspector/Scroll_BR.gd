extends ScrollContainer
# Scroll_BR

var amount:int = 1
var type:String
var naem:String
var val:int

var hand_owner_id:int


func spawn() -> void:
	var info  = {
		"type":type,
		"name":naem,
		"amount":amount,
		"value":val,
		"owner_id":hand_owner_id
		}
	Spawner.request_spawn(info)
	get_node("vb/amount").amount = 1



func set_scroll_for_selection(_type,_naem,_val) -> void:
	type = _type
	naem = _naem
	val = _val
	
	
	
	if naem == "Hand":
		$vb/owner.visible = true
	else:
		$vb/owner.visible = false



func _on_amount_amount_changed(am):
	amount = am


func _on_owner_on_owner_changed(ownerid):
	hand_owner_id = ownerid
