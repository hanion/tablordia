extends ScrollContainer
# UNO


onready var hs = get_parent().get_parent()

func pres(id:int) -> void:
	var info := {
		"type":"Card",
		"name":"Uno Card",
		"value":id
		}
	hs.selected(info)



func _on_m0_pressed():
	pres(0)


func _on_m1_pressed():
	pres(1)


func _on_m2_pressed():
	pres(2)


func _on_m3_pressed():
	pres(3)


func _on_m4_pressed():
	pres(4)


func _on_m5_pressed():
	pres(5)


func _on_m6_pressed():
	pres(6)


func _on_m7_pressed():
	pres(7)


func _on_m8_pressed():
	pres(8)


func _on_m9_pressed():
	pres(9)


func _on_m10_pressed():
	pres(10)


func _on_m11_pressed():
	pres(11)


func _on_m12_pressed():
	pres(12)


func _on_m13_pressed():
	pres(13)


func _on_m14_pressed():
	pres(14)


