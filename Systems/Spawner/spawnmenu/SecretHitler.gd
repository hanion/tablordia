extends ScrollContainer
# Secret Hitler


onready var hs = get_parent().get_parent()

func pres(id:int) -> void:
	var info := {
		"type":"Card",
		"name":"SH Card",
		"value":id
		}
	hs.selected(info)




func _on_msh_pressed() -> void:
	pres(0)


func _on_msh2_pressed() -> void:
	pres(1)


func _on_msh3_pressed() -> void:
	pres(2)


func _on_msh4_pressed() -> void:
	pres(3)


func _on_msh5_pressed() -> void:
	pres(4)


func _on_msh6_pressed() -> void:
	pres(5)


func _on_msh7_pressed() -> void:
	pres(6)


func _on_msh8_pressed() -> void:
	pres(7)


func _on_msh9_pressed() -> void:
	pres(8)


func _on_msh10_pressed() -> void:
	var info := {
		"type":"Game",
		"name":"SH"
		}
	hs.selected(info)
