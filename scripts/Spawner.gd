extends Spatial

const br_card_pl = preload("res://Games/br/br_card.tscn")
const br_board_pl = preload("res://Games/br/br.tscn")
const Board_chess_pl = preload("res://Games/chess/chess.tscn")
const uno_card_pl = preload("res://Games/uno/uno_card.tscn")
const UNO_pl = preload("res://Games/uno/UNO.tscn")
const _52_pl = preload("res://Games/52/52.tscn")
const _52_card_pl = preload("res://Games/52/card_52.tscn")
const snr_card_pl = preload("res://Games/snr/snr_card.tscn")


const deck_pl = preload("res://Games/deck.tscn")
const hand_pl = preload("res://Games/hand.tscn")

var cards_folder

var resource_index:int = 0
var item_index:int = 0
var hand_index:int = 0
var deck_index:int = 0

var uno_index:int = 0
var card_52_index:int = 0
var snr_card_index:int = 0



func request_spawn(info) -> void:
	NetworkInterface.request_spawn(info)

func receive_requested_spawn(info) -> void:
	_spawn(info)

func _spawn(info) -> void:
#	var info  = {
#		"type":type,
#		"name":name,
#		"amount":amount,
#		"value":val,
#		"owner_id":hand_owner_id,
#		"in_deck":deck name,
#		"in_dispenser":self.name,
#		"translation":spawn translation
#		}
	
	match info["type"]:
		"Game":
			spawn_Game(info)
		"Misc":
			spawn_Misc(info)
		"Card":
			spawn_Card(info)
		_:
			print("!!!Spawner: Unknown type to spawn,\n    info: ",info)
			push_error("Spawner: Unknown type to spawn")




func spawn_Game(info) -> void:
	var board
	match info["name"]:
		"Chess Board":
			board = Board_chess_pl.instance()
		"Board Royale":
			board = br_board_pl.instance()
		"UNO":
			board = UNO_pl.instance()
		"52":
			board = _52_pl.instance()
		_:
			return
	
	get_node("/root/Main").add_child(board)
	List.paths[board.name] = board.get_path()
	tweenit(board, Vector3(0,-0.1,0), Vector3(0,0.004,0))



func spawn_Misc(info) -> void:
	var misc
	
	match info["name"]:
		"Deck":
			misc = deck_pl.instance()
			misc.set_name("deck"+str(deck_index))
			deck_index += 1
			cards_folder.add_child(misc)
		"Hand":
			misc = hand_pl.instance()
			misc.set_name("hand"+str(hand_index))
			hand_index += 1
			cards_folder.add_child(misc)
			
			var ownerid = info["owner_id"]
			var ownername = List.players[ownerid]["name"]
			var ownercolor = List.players[ownerid]["color"]
			misc.set_hand_owner(ownerid,ownername)
			misc.set_hand_color(ownercolor)
			
			
	
	List.paths[misc.name] = misc.get_path()
	tweenit(misc, Vector3(0,-0.1,0), Vector3(0,0.4,0))



func spawn_Card(info) -> void:
	var crd : card
	match info["name"]:
		"item":
			crd = br_card_pl.instance() as br_card
			crd.set_name("item"+str(item_index))
			item_index += 1
			crd.is_item = true
			crd.set_type("item")
			crd.update_material()
		"resource":
			crd = br_card_pl.instance() as br_card
			crd.set_name("item"+str(resource_index))
			resource_index += 1
			crd.is_resource = true
			crd.set_type("resource")
			crd.update_material()
			
		"Uno Card":
			crd = uno_card_pl.instance() as uno_card
			crd.set_name("unoc"+str(uno_index))
			uno_index += 1
		"52 Card":
			crd = _52_card_pl.instance() as card_52
			crd.set_name("c52_"+str(card_52_index))
			card_52_index += 1
		"SNR Card":
			crd = snr_card_pl.instance() as snr_card
			crd.set_name("snrc"+str(snr_card_index))
			snr_card_index += 1
	
	
	#spawn
	cards_folder.add_child(crd)
	List.paths[crd.name] = crd.get_path()
	
	
	
	crd.card_value = info["value"]
	if info.has("value_second"):
		crd.card_value_second = info["value_second"]
	
	crd.set_is_hidden(false)
	
	
	if info.has("in_deck"):
		var dek = Std.get_object(info["in_deck"]) as deck
		dek.add_to_deck(crd,true,false)
	
	
	if info.has("in_dispenser"):
		crd.is_in_dispenser = true
		crd.in_dispenser = Std.get_object(info["in_dispenser"])
		crd.set_is_hidden(true)
	
	
	
	
	if info.has("translation"):
		var tr = info["translation"]
		tweenit(crd, tr - Vector3(0,0.1,0), tr)
	else:
		tweenit(crd, Vector3(0,0.04,0), Vector3(0,1,0))






onready var tween = $Tween
func tweenit(obj: Spatial, first, final) -> void:
#	tween.stop_all()
	var old_scale = obj.scale
	tween.interpolate_property(
		obj,
		"scale",
		Vector3(0,0,0),
		old_scale,
		Std.tween_duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
		)
	
	tween.interpolate_property(
		obj,
		"translation",
		first,
		final,
		Std.tween_duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
		)
	tween.start()
