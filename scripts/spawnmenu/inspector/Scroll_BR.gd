extends ScrollContainer
# Scroll_BR

var amount:int = 1
var type:String
var naem:String
var val:int

const br_card_path = "res://scenes/br_card.tscn"

var off_y = 0.04

onready var tween = get_node("../../../../../../../Tween")


func _on_amount_amount_changed(am):
	amount = am


func spawn() -> void:
	Spawner.request_spawn(type,val,amount)
	get_node("vb/amount").amount = 1







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
