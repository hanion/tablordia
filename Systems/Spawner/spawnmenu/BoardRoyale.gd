extends TabContainer
# Board Royale

var igrid
func _ready():
	igrid = get_node("Items/Grid")
	for i in igrid.get_children():
		i = i as Button
		i.connect("pressed",self,"_br_item_pressed")


func _br_item_pressed() -> void:
	for i in igrid.get_children():
		i = i as Button
		if i.pressed:
			var val = int(i.name.right(1))
			var inspector_text = i.get_node("vb/Label").text
			
			var info := {
				"type":"Card",
				"name":"item",
				"inspector_text":inspector_text,
				"value":val
				}
			get_parent().get_parent().selected(info)
			return



func br_pressed(naame, naem, val) -> void:
	var info := {
		"type":"Card",
		"name":naame,
		"inspector_text":naem,
		"value":val
		}
	get_parent().get_parent().selected(info)



func _on_s0_pressed():
	br_pressed("resource","Wood",1)



func _on_s1_pressed():
	br_pressed("resource","Stone",2)


func _on_s2_pressed():
	br_pressed("resource","Food",3)


func _on_s3_pressed():
	br_pressed("resource","Steel",4)


func _on_s4_pressed():
	br_pressed("resource","Gold",5)



func _on_m1_pressed():
	var info := {
		"type":"Game",
		"name":"Board Royale"
		}
	get_parent().get_parent().selected(info)


func _on_m2_pressed():
	var info := {
		"type":"Misc",
		"name":"Hand"
		}
	get_parent().get_parent().selected(info)
