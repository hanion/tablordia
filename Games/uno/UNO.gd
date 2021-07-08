extends Spatial

const my_paths := {
	"uno_draw_deck":"/root/Main/UNO/uno_draw_deck",
	"uno_discard_deck":"/root/Main/UNO/uno_discard_deck"
	}

var deste := []

onready var uno_draw_deck = $uno_draw_deck

func _ready() -> void:
	write_paths()
	
	yield(get_tree().create_timer(1),"timeout")
	if not get_tree().is_network_server(): return
	create_draw_deck()
	prepare_next_card()


func write_paths() -> void:
	for objname in my_paths.keys():
		if List.paths.has(objname):
			push_error("List already has this objects path")
		List.paths[objname] = my_paths[objname]



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



func prepare_next_card() -> void:
	var nev_card = deste.pop_back()
	
	if nev_card == null: return
	
	var info := {
		"type":"Card",
		"name":"Uno Card",
		"amount":1,
		"value":nev_card.x,
		"value_second":nev_card.y,
		"in_deck":"uno_draw_deck",
		"translation":(uno_draw_deck.translation + Vector3(0,1,0))
	}
	
	Spawner.request_spawn(info)


func _on_uno_draw_deck_removed_card_from_deck():
	if not get_tree().is_network_server(): return
	prepare_next_card()


