extends Spatial

func get_game_spawn_name() -> String:
	return "SH"



func _ready() -> void:
	write_paths()


func write_paths() -> void:
	var my_paths := {}
	
	for ch in get_children():
		my_paths[ch.name] = ch.get_path()
	
	my_paths[name] = get_path()
	
	List.feed_my_paths(my_paths)
