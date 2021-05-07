extends TabContainer
# Board Royale

var igrid
func _ready():
	igrid = get_node("Items/Grid")
	for i in igrid.get_children():
		i = i as Button
		i.connect("pressed",self,"_br_item_pressed")


func _br_item_pressed() -> void:
	var naem
	var val
	
	for i in igrid.get_children():
		i = i as Button
		if i.pressed:
			naem = i.get_node("vb/Label").text
			val = int(i.name.right(1))
			get_parent().get_parent().selected("br", "item", naem, val)
			return



func br_pressed(type, naem, val) -> void:
	get_parent().get_parent().selected("br", type, naem, val)



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
	br_pressed("misc","Board",1)
	









