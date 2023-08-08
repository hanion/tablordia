extends Spatial

const br_card_pl = preload("res://Games/br/br_card.tscn")
const br_board_pl = preload("res://Games/br/br.tscn")
const Board_chess_pl = preload("res://Games/chess/chess.tscn")
const uno_card_pl = preload("res://Games/uno/uno_card.tscn")
const UNO_pl = preload("res://Games/uno/UNO.tscn")
const _52_pl = preload("res://Games/52/52.tscn")
const _52_card_pl = preload("res://Games/52/card_52.tscn")
const snr_card_pl = preload("res://Games/snr/snr_card.tscn")
const sh_pl = preload("res://Games/sh/sh.tscn")
const sh_card_pl = preload("res://Games/sh/sh_card.tscn")

const expansion_pl = preload("res://assets/br/expansions/Expansion_Pack.tscn")


const deck_pl = preload("res://InGame/Deck/deck.tscn")
const hand_pl = preload("res://InGame/Hand/hand.tscn")

var cards_folder

var resource_index:int = 0
var item_index:int = 0
var exp_skill_index:int = 0
var exp_island_index:int = 0
var exp_military_index:int = 0
var hand_index:int = 0
var deck_index:int = 0
var game_52_index:int = 0
var game_sh_index:int = 0
var game_chess_index:int = 0
var game_uno_index:int = 0

var expansion_index:int = 0

var uno_index:int = 0
var card_52_index:int = 0
var snr_card_index:int = 0
var sh_card_index:int = 0

onready var request_collector = $request_collector

func request_spawn(info) -> void:
	NetworkInterface.request_spawn(info)

func receive_requested_spawn(info) -> void:
	_spawn(info)
	if get_tree().is_network_server():
		request_collector.collect(info)

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
			for _a in range(info["amount"]):
				spawn_Card(info)
		"Expansion":
			spawn_Expansion(info)
		_:
			UMB.logs(2,"Spawner","Unknown type to spawn,\n    info: "+str(info))
			print("!!!Spawner: Unknown type to spawn,\n    info: ",info)
			push_error("Spawner: Unknown type to spawn")
			return
	
#	there is no more need for this in release
#	if not info.has("no UMB"):
#		if info["name"] == "resource": return
#		if info["name"] == "item": return
#		UMB.log(1,"Spawner","Spawned "+info["type"]+" "+info["name"])




func spawn_Game(info) -> void:
	var board
	match info["name"]:
		"Chess Board":
			board = Board_chess_pl.instance()
			board.game_chess_index = str(game_chess_index)
			game_chess_index += 1
		"Board Royale":
			board = br_board_pl.instance()
		"UNO":
			board = UNO_pl.instance()
			for ch in board.get_children():
				ch.name += str(game_uno_index)
			game_uno_index += 1
		"52":
			board = _52_pl.instance()
			board.get_child(0).name += str(game_52_index)
			game_52_index +=1
		"SH":
			board = sh_pl.instance()
			for ch in board.get_children():
				ch.name += str(game_sh_index)
			game_sh_index += 1
		_:
			return
	
	
	get_node("/root/Main").add_child(board,true)
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
			
			# owner player disconnected
			# before this client joined
			if not List.players.has(ownerid):
				yield(get_tree().create_timer(0.1),"timeout")
				if not List.players.has(ownerid):
					List.paths[misc.name] = misc.get_path()
					return
			
			if not List.players[ownerid].has("name"):
				yield(get_tree().create_timer(0.1),"timeout")
				if not List.players[ownerid].has("name"):
					List.paths[misc.name] = misc.get_path()
					return
			var ownername = List.players[ownerid]["name"]
			var ownercolor = List.players[ownerid]["color"]
			misc.set_hand_owner(ownerid,ownername)
			misc.set_hand_color(ownercolor)
			misc.others_can_touch = info["others_can_touch"]
			
			
	
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
			crd.set_name("resource"+str(resource_index))
			resource_index += 1
			crd.is_resource = true
			crd.set_type("resource")
			crd.update_material()
		
		"exp_island_item":
			crd = br_card_pl.instance() as br_card
			crd.set_name("item"+str(item_index))
			item_index += 1
			crd.is_item = true
			crd.set_type("item")
			crd.update_material()
		
		"exp_island_resource":
			crd = br_card_pl.instance() as br_card
			crd.set_name("resource"+str(resource_index))
			resource_index += 1
			crd.is_resource = true
			crd.set_type("resource")
			crd.update_material()
		
		"exp_skill":
			crd = br_card_pl.instance() as br_card
			crd.set_name("exp_skill"+str(exp_skill_index))
			exp_skill_index += 1
			crd.is_expansion_skill = true
			crd.update_material()
		"exp_military":
			crd = br_card_pl.instance() as br_card
			crd.set_name("exp_military"+str(exp_military_index))
			exp_military_index += 1
			crd.is_expansion_military = true
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
		"SH Card":
			crd = sh_card_pl.instance() as sh_card
			crd.set_name("shc"+str(sh_card_index))
			sh_card_index += 1
		
	
	
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



func spawn_Expansion(info) -> void:
	var expansion = expansion_pl.instance()
	
	expansion.set_name(info["name"]+"_pack_"+str(expansion_index))
	
	expansion.expansion_name = info["name"]
	
	if info.has("value_second"):
		expansion.pack_second_value = info["value_second"]
	
	for ch in expansion.get_children():
		ch.name += str(expansion_index)
	
	expansion_index += 1
	
	get_node("/root/Main").add_child(expansion,true)
	List.paths[expansion.name] = expansion.get_path()
	
	if info.has("translation"):
		var tr = info["translation"] as Vector3
		assert(tr, "translation must be a valid Vector3")
		tweenit(expansion, Vector3(0,-0.1,0), tr)
	else:
		tweenit(expansion, Vector3(0,-0.1,0), Vector3(0,0.004,0))










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
