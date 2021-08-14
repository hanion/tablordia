extends Button

onready var spawn_panel = get_node("../../SpawnPanel")

func _on_Button_pressed():
	if spawn_panel.visible:
		spawn_panel.close_menu()
	else:
		spawn_panel.open_menu()
