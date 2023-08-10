extends Spatial
class_name ContainerPrep 


var pcon := [] # Array[card_data(card_value,card_value_second)]

var prepping_con : container
var child_translation : Vector3 = Vector3.UP

var spawn_name : String = ""

func init(_spawn_name : String) -> void:	
	# prep con
	var info := {
		"type":"Misc",
		"name":"Container",
		"translation":child_translation
		}
	prepping_con = Spawner._spawn(info)
	
	if not get_tree().is_network_server(): 
		queue_free()
		return
	
	
	
	spawn_name = _spawn_name
	write_paths()
	yield(get_tree().create_timer(0.1),"timeout")
	
	create_draw_container()
	
	if get_tree().is_network_server():
		NetworkInterface.send_container_data_to_client(0,prepping_con.name,pcon)
	
	yield(get_tree().create_timer(0.1),"timeout")
	get_draw_container_up()
	
	
	 
	yield(get_tree().create_timer(1),"timeout")
	List.reparent_child(prepping_con, get_parent())
	queue_free()



func add_to_pcon(value, value_second) -> void:
	var card_data = {
		"name":spawn_name,
		"value":value,
		"value_second":value_second
	}
	pcon.append(card_data)


func create_draw_container() -> void:
	print("ContainerPrep: base function !!!")











func write_paths() -> void:
	var my_paths := {}
	
	for ch in get_children():
		my_paths[ch.name] = ch.get_path()
	
	my_paths[name] = get_path()
	
	List.feed_my_paths(my_paths)



func shuffle(dict:Array) -> Array:
	randomize()
	
	var siz = dict.size()
	
	for i in range(siz):
		i = siz - i
		i -= 1
		
		if i == 0: continue
		
		var ran = randi() % i
		
		var first_val = dict[i]
		var second_val = dict[ran]
		
		dict[i] = second_val
		dict[ran] = first_val
	
	return dict





func get_draw_container_up() -> void:
	prepping_con.global_translation = child_translation
	var state = {
		prepping_con.name:{
			"O": Std.get_global(prepping_con),
			"R":prepping_con.rotation
		}
	}

	NetworkInterface.collect_state(state)
	
