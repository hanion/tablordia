extends ScrollContainer
# Scroll_BR

var amount:int = 1
var type:String
var naem:String
var val:int

var hand_owner_id:int

const br_card_path = "res://scenes/br_card.tscn"

var off_y = 0.04

onready var tween = get_node("../../../../../../../Tween")

func spawn() -> void:
	var info  = {
		"type":type,
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
		





func tweenit(obj: Spatial, first, final) -> void:
#	tween.stop_all()
	var old_scale = obj.scale
	tween.interpolate_property(
		obj,
		"scale",
		Vector3(0,0,0),
		old_scale,
		Std.tween_duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
		)
	
	tween.interpolate_property(
		obj,
		"translation",
		first,
		final,
		Std.tween_duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
		)
	tween.start()



func _on_amount_amount_changed(am):
	amount = am


func _on_owner_on_owner_changed(ownerid):
	hand_owner_id = ownerid
