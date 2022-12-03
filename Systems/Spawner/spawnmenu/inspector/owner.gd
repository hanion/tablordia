extends HBoxContainer

signal on_owner_changed(ownerid)

export(NodePath) var spawnpanel

onready var om = $OptionButton as OptionButton

# warning-ignore:return_value_discarded
func _ready():
	get_node(spawnpanel).connect("on_menu_opened",self,"on_sp_menu_opened")


func on_sp_menu_opened() -> void:
	om.clear()
	
	for playerid in List.players:
		var playername = List.players[playerid]["name"]
		if playername == "server": continue
		om.add_item(playername)
	
	_on_OptionButton_item_selected(0)

func _on_OptionButton_item_selected(index):
	var nam = om.get_item_text(index)
	
	for playerid in List.players:
		var playername = List.players[playerid]["name"]
		if nam == playername:
			emit_signal("on_owner_changed",playerid)
