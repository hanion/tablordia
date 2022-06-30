extends Node

var players := {
#	id:{
#			"name": name,
#			"color": color
#			"class": "class"
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


func remove_player(var id: int) -> void:
	if players.has(id):
		var pname = players[id]["name"]
		var _er = players.erase(id)
		print("L: player removed from list, name: '",pname,"', id: ",id)
	else:
		print("L: player does not exist, id: ",id)


func remote_set_class(var id: int, var clas: String) -> void:
	rpc("set_class",id,clas)
remote func set_class(var id: int, var clas: String) -> void:
	if not players.has(id): return
	players[id]["class"] = clas




func reparent_child(var child: Spatial, var new_parent: Spatial):
	
	if not paths.has(child.name):
		push_error("L: child name is not in paths dictionary")
		return 
	
	
	
	var old_child_local_pos =  child.translation + child.get_parent().translation
#	var old_child_local_pos =  Std.get_global(child)
	
	child.get_parent().remove_child(child)
	child.translation = old_child_local_pos
	new_parent.add_child(child)
	child.translation = old_child_local_pos
	
	
	
	paths[child.name] = (str(new_parent.get_path()) + "/" + child.name)
#	print("reparented : ",child.name," to ",paths[child.name]
#		,"\n   & returned:",old_child_local_pos,child.translation)
	
	return old_child_local_pos


func feed_my_paths(var mp:Dictionary) -> void:
	for objname in mp.keys():
		if List.paths.has(objname):
			push_error("List already has this objects path")
		List.paths[objname] = mp[objname]



var paths := {
	"node_name":"node_path",
	"table":"/root/Main/tablo/table"#,
#	"deck":"/root/Main/cards/deck"
}

"""
	vs vs vb vb
	"card":"/root/Main/cards/card",
	"card2":"/root/Main/cards/card2",
	"card3":"/root/Main/cards/card3",
	"card4":"/root/Main/cards/card4",
	"card5":"/root/Main/cards/card5"
"""


