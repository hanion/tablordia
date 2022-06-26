extends Spatial


var deste := [] # Array[Vector2(card_value,card_value_second)]

onready var uno_draw_deck = get_child(0)

func _ready() -> void:
	write_paths()
	
	yield(get_tree().create_timer(1),"timeout")
	
	if not get_tree().is_network_server(): return
	create_draw_deck()
	spawn_all_cards()


func write_paths() -> void:
	var my_paths := {}
	
	for ch in get_children():
		my_paths[ch.name] = ch.get_path()
	
	my_paths[name] = get_path()
	
	List.feed_my_paths(my_paths)


func create_draw_deck() -> void:
	
	for colour in range(4):
		deste.append(Vector2(0,colour)) # 0
		
		for i in range(1,13):
			deste.append(Vector2(i,colour)) # 1-9 + block,reverse,+2
			deste.append(Vector2(i,colour)) # 1-9 + block,reverse,+2

		deste.append(Vector2(14,colour)) # color_change
		deste.append(Vector2(13,colour)) # +4
	
	print("UNO: created deste ")
	
	deste = shuffle(deste)


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





func spawn_all_cards() -> void:
	for c in deste:
		yield(get_tree().create_timer(0.001),"timeout")
		
		var info := {
			"type":"Card",
			"name":"Uno Card",
			"amount":1,
			"value":c.x,
			"value_second":c.y,
			"in_deck":uno_draw_deck.name,
			"translation":(uno_draw_deck.translation + Vector3(0,-5,0)),
			"no UMB":true
		}
		
		Spawner.request_spawn(info)
	
	yield(get_tree().create_timer(0.01),"timeout")
	get_draw_deck_up()

func get_draw_deck_up() -> void:
	uno_draw_deck.translation = Vector3(0,0,0)
	var state = {
		uno_draw_deck.name:{
			"O": Std.get_global(uno_draw_deck),
			"R":uno_draw_deck.rotation
		}
	}
	
	NetworkInterface.collect_state(state)


#
#func prepare_next_card() -> void:
#	return
#	var nev_card = deste.pop_back()
#
#	if nev_card == null:
#		print("UNO: No more cards left in drawing deck.")
#		uno_draw_deck.queue_free()
#		return
#
#	var info := {
#		"type":"Card",
#		"name":"Uno Card",
#		"amount":1,
#		"value":nev_card.x,
#		"value_second":nev_card.y,
#		"in_deck":"uno_draw_deck",
#		"translation":(uno_draw_deck.translation + Vector3(0,1,0))
#	}
#
#	Spawner.request_spawn(info)
#
#
#func _on_uno_draw_deck_removed_card_from_deck():
#	if not get_tree().is_network_server(): return
#	prepare_next_card()


