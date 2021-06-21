extends ScrollContainer
# Scroll_Boards

var amount:int = 1
var type:String
var naem:String
var val:int


func spawn() -> void:
	var info  = {
		"type":type,
		"name":naem,
		"amount":amount
		}
	Spawner.request_spawn(info)
	get_node("vb/amount").amount = 1



func set_scroll_for_selection(_type,_naem,_val) -> void:
	type = _type
	naem = _naem
	val = _val



func _on_amount_amount_changed(am):
	amount = am

