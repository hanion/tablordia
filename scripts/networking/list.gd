extends Node

var players := {
#	id:{
#			"name": name,
#			"color": color
#		}
}

func _clear_list():
	players.clear()
	print("L: list cleard")


func add_player(var id, var p: Dictionary = {}) -> void:
	var new_dict := {}
	
	if p.has("name"):
		new_dict["name"] = p["name"]
	if p.has("color"):
		new_dict["color"] = p["color"]
	
	
	players[id] = new_dict
	
#	print("L: player added to List, id: ",id)
	


func remove_player(var id: int) -> void:
	if players.has(id):
		var pname = players[id]["name"]
		var _er = players.erase(id)
		print("L: player removed from list, name: '",pname,"', id: ",id)
	else:
		print("L: player does not exist, id: ",id)



func reparent_child(var child: Spatial, var new_parent: Spatial):
	if not paths.has(child.name):
		push_error("L: child name is not in paths dictionary")
		return 
	
	
	var old_child_local_pos =  child.translation
	
	child.get_parent().remove_child(child)
	new_parent.add_child(child)
	
	
	
	paths[child.name] = (str(new_parent.get_path()) + "/" + child.name)
#	print("reparented : ",child.name," to ",paths[child.name]
#		,"\n   & returned:",old_child_local_pos)
	return old_child_local_pos



var paths := {
	"node_name":"node_path"
	,
	"table":"/root/Main/tablo/table"
	
}

"""
	vs vs vb vb
	"card":"/root/Main/cards/card",
	"card2":"/root/Main/cards/card2",
	"card3":"/root/Main/cards/card3",
	"card4":"/root/Main/cards/card4",
	"card5":"/root/Main/cards/card5"
"""


