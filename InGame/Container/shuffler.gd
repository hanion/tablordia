extends Node

func shuffle_container(con : container) -> void:
	if not get_tree().is_network_server(): 
		con.data_inv.clear()
		# clear spawned cards
		for crd in con.card_inv:
			if crd and is_instance_valid(crd):
				crd.queue_free()
		
		return
	
	var datas : Array = con.data_inv.duplicate(true)
	con.data_inv.clear()
	
	Std.shuffle_array(datas)
	
	# save spawned cards as data
	for crd in con.card_inv:
#		print("adding id as ", crd.name)
		var info = {
			"name":get_spawn_name_from_card_name(crd.name),
			"id":crd.name,
			"value":crd.card_value,
			"value_second":crd.card_value_second
		}
		datas.append(info)
	
	# clear spawned cards
	for crd in con.card_inv:
		crd.queue_free()
	con.card_inv.clear()
	
	Std.shuffle_array(datas)
	
	
	# shuffling ended, send to everyone
	NetworkInterface.send_container_data_to_client(0,con.name, datas)
	
#	# add shuffled data
#	for data in datas:
#		con.add_data_to_container(data)
	



const _correct_spawn_names := [
	"item", "resource", 
	"exp_island_item", "exp_island_resource", "exp_skill", "exp_military"
]

func get_spawn_name_from_card_name(card_name : String) -> String:
	if card_name in _correct_spawn_names:
		return card_name
	
	match card_name:
		"c52":
			return "52 Card"
		"unoc":
			return "Uno Card"
		"shc":
			return "SH Card"
		"snrc":
			return "SNR Card"
		_:
			var cname : String = card_name
			if cname.length() < 3: 
				push_error("cname.length() < 3  in shuffler "+ cname)
				return ""
			return get_spawn_name_from_card_name(cname.left(cname.length()-1))
	

