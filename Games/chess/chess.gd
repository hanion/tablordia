extends Spatial

const my_paths := {
	"chess_board":"/root/Main/chess/chess_board"
	}

func _ready() -> void:
	get_paths()
	write_paths()
	
	if not get_tree().is_network_server(): return


func get_paths() -> void:
	var w = $w.get_children()
	var b = $b.get_children()
	
	var base_w = "/root/Main/chess/w/"
	var base_b = "/root/Main/chess/b/"
	
	
	for piece in w:
		var final_path: String = base_w + piece.name
		my_paths[piece.name] = final_path
	for piece in b:
		var final_path: String = base_b + piece.name
		my_paths[piece.name] = final_path
	

func write_paths() -> void:
	for objname in my_paths.keys():
		if List.paths.has(objname):
			push_error("List already has this objects path")
		List.paths[objname] = my_paths[objname]
	
