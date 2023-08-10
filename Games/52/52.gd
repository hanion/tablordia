extends ContainerPrep

func get_game_spawn_name() -> String:
	return "52"

func _ready() -> void:
	init("52 Card")


func create_draw_container() -> void:
	for sv in range(4):
		for v in range(1,14):
			add_to_pcon(v,sv)
	
	print("52: created deste ")
	
	Std.shuffle_array(pcon)

