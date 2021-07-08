extends ScrollContainer
# Boards


onready var hs = get_parent().get_parent()

func _on_m1_pressed():
	var info := {
		"type":"Game",
		"name":"Board Royale"
		}
	hs.selected(info)


func _on_m2_pressed():
	var info := {
		"type":"Game",
		"name":"Chess Board"
		}
	hs.selected(info)


func _on_m3_pressed():
	var info := {
		"type":"Misc",
		"name":"Hand"
		}
	hs.selected(info)


func _on_m4_pressed():
	var info := {
		"type":"Misc",
		"name":"Deck"
		}
	hs.selected(info)
	
