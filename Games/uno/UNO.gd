extends ContainerPrep

func get_game_spawn_name() -> String:
	return "UNO"


func _ready() -> void:
	init("Uno Card")



func create_draw_container() -> void:
	for colour in range(4):
		add_to_pcon(0,colour) # 0
		
		for i in range(1,13):
			
			add_to_pcon(i,colour) # 1-9 + block,reverse,+2
			add_to_pcon(i,colour) # 1-9 + block,reverse,+2

		add_to_pcon(14,colour) # color_change
		add_to_pcon(13,colour) # +4
	
	Std.shuffle_array(pcon)


	print("UNO: created pcon")
