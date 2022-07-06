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

func _on_m51_pressed():
	var info := {
		"type":"Game",
		"name":"UNO"
		}
	hs.selected(info)


func _on_m5_pressed():
	var info := {
		"type":"Game",
		"name":"52",
		"inspector_text":"Deck of Cards"
		}
	hs.selected(info)






func _on_m6_pressed():
	var info := {
		"type":"Card",
		"name":"SNR Card",
		"value":0
		}
	hs.selected(info)

func _on_m7_pressed():
	var info := {
		"type":"Card",
		"name":"SNR Card",
		"value":1
		}
	hs.selected(info)


func _on_m8_pressed() -> void:
	var info := {
		"type":"Game",
		"name":"SH",
		"inspector_text":"Secret Hitler"
		}
	hs.selected(info)



