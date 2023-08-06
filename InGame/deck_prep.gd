extends Spatial
class_name DeckPrep 


var pdeck := [] # Array[Vector2(card_value,card_value_second)]

onready var prepping_deck = get_child(0)




func init(spawn_type: String, spawn_name) -> void:
	write_paths()
	yield(get_tree().create_timer(0.1),"timeout")
	if not get_tree().is_network_server(): return
	create_draw_deck()
	spawn_all_cards(spawn_type, spawn_name)
	
	yield(get_tree().create_timer(0.1),"timeout")
	get_draw_deck_up()
	yield(get_tree().create_timer(0.1),"timeout")
	get_last_card_tweenup()
	



func add_to_pdeck(value, value_second) -> void:
	pdeck.append(Vector2(value, value_second))


func create_draw_deck() -> void:
	for i in range(8):
		pdeck.append(i)
	
	print("DeckPrep: created pdeck")
	
	pdeck = shuffle(pdeck)











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





func spawn_all_cards(type:String, nam:String) -> void:
	for c in pdeck:
		yield(get_tree().create_timer(0.001),"timeout")
		
		var info := {
			"type":type,
			"name":nam,
			"amount":1,
			"value":c.x,
			"value_second":c.y,
			"in_deck":prepping_deck.name,
			"translation":(prepping_deck.translation + Vector3(0,-5,0)),
			"no UMB":true
		}
		
		Spawner.request_spawn(info)

func get_draw_deck_up() -> void:
	prepping_deck.translation = Vector3(0,0,0)
	var state = {
		prepping_deck.name:{
			"O": Std.get_global(prepping_deck),
			"R":prepping_deck.rotation
		}
	}
	
	NetworkInterface.collect_state(state)


func get_last_card_tweenup() -> void:
	var last_card = prepping_deck.env.back()
	last_card.translation = Vector3(0,0.1,0)
	var state = {
		last_card.name:{
			"O": Std.get_global(last_card),
			"R":last_card.rotation
		}
	}
	
	NetworkInterface.collect_state(state)
