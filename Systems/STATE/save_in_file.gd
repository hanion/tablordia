extends Node

const SAVE_DIR = "user://saves/"

var save_path = SAVE_DIR + "world_state.dat"

func save_world_state_to_file() -> void:
	
	var dir = Directory.new()
	if not dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)
	
	
	var file = File.new()
	var er = file.open(save_path, File.WRITE)
	if er == OK:
		file.store_var(STATE.WORLD_STATE)
		file.close()
		print("STATE:data: 	world state saved to file in    ", save_path)
	else:
		print("STATE:data: 	!! Error while saving world state. ",er)



func load_world_state_from_file() -> void:
	var file = File.new()
	if file.file_exists(save_path):
		
		var er = file.open(save_path, File.READ)
		if er == OK:
			var world_state = file.get_var()
			file.close()
			
			print("STATE:data: 	world state loaded from file in ", save_path)
			
			STATE.LOAD_STATE(world_state)
			
		else:
			print("STATE:data: 	!! Error while loading world state. ",er)








