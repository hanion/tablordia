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


func skill_pack_pressed(value : int) -> void:
	var info := {
		"type":"Expansion",
		"name":"exp_skill",
		"inspector_text":"Skills Expansion",
		"value_second": value
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


func _on_e1_pressed():
	br_pressed("exp_skill","Skills Expansion Pack",-1)


func _on_e2_pressed():
	skill_pack_pressed(0)


func _on_e3_pressed():
	skill_pack_pressed(1)


func _on_e4_pressed():
	skill_pack_pressed(2)


func _on_e5_pressed():
	skill_pack_pressed(3)

func _on_e6_pressed():
	skill_pack_pressed(4)

func _on_e7_pressed():
	skill_pack_pressed(5)


func _on_es2_1_pressed():
	br_pressed("exp_skill","Skills Expansion Pack",-1)

func _on_es2_2_pressed():
	skill_pack_pressed(6)

func _on_es2_3_pressed():
	skill_pack_pressed(7)

func _on_es2_4_pressed():
	skill_pack_pressed(8)

func _on_es2_5_pressed():
	skill_pack_pressed(9)

func _on_es2_6_pressed():
	skill_pack_pressed(10)

func _on_es2_7_pressed():
	skill_pack_pressed(11)



func _on_em1_pressed():
	var info := {
		"type":"Expansion",
		"name":"exp_military",
		"inspector_text":"Military Expansion"
		}
	get_parent().get_parent().selected(info)

