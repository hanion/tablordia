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

const hand_pl = preload("res://InGame/Hand/hand.tscn")
const container_pl = preload("res://InGame/Container/container.tscn")

var cards_folder

var br_cards_index:int = 0
var resource_index:int = 0
var item_index:int = 0
var exp_skill_index:int = 0
var exp_island_index:int = 0
var exp_military_index:int = 0
var hand_index:int = 0

var container_index:int = 0
var game_52_index:int = 0
var game_sh_index:int = 0
var game_chess_index:int = 0
var game_uno_index:int = 0

var expansion_index:int = 0

var uno_index:int = 0
var card_52_index:int = 0
var snr_card_index:int = 0
var sh_card_index:int = 0


func request_spawn(info) -> void:
	NetworkInterface.request_spawn(info)

func receive_requested_spawn(info) -> void:
# warning-ignore:return_value_discarded
	_spawn(info)

func _spawn(info) -> Spatial:
#	var info  = {
#		"type":type,
#		"name":name,
#		"spawned_name":spawned_name
#		"amount":amount,
#		"value":val,
#		"owner_id":hand_owner_id,
#		"translation":spawn translation
#		}
	
	match info["type"]:
		"Game":
			return spawn_Game(info)
		"Misc":
			return spawn_Misc(info)
		"Card":
#			for _a in range(info["amount"]):
			return spawn_Card(info)
		"Expansion":
			return spawn_Expansion(info)
		_:
			UMB.logs(2,"Spawner","Unknown type to spawn,\n    info: "+str(info))
			print("!!!Spawner: Unknown type to spawn,\n    info: ",info)
			push_error("Spawner: Unknown type to spawn")
	
	return null


func spawn_Game(info) -> Spatial:
	var board
	match info["name"]:
		"Chess Board":
			board = Board_chess_pl.instance()
			board.game_chess_index = str(game_chess_index)
			game_chess_index += 1
		"Board Royale":
			board = br_board_pl.instance()
			if info.has("do_not_init") and info["do_not_init"]:
				board.init_br_on_ready = false
		"UNO":
			board = UNO_pl.instance()
			for ch in board.get_children():
				ch.name += str(game_uno_index)
			game_uno_index += 1
		"52":
			board = _52_pl.instance()
			for ch in board.get_children():
				ch.name += str(game_52_index)
			game_52_index +=1
		"SH":
			board = sh_pl.instance()
			for ch in board.get_children():
				ch.name += str(game_sh_index)
			game_sh_index += 1
		_:
			return null
	
	
	cards_folder.add_child(board,true)
	List.paths[board.name] = board.get_path()
	tweenit(board, Vector3(0,0.004,0), Vector3(0,0.004,0))
	info["spawned_name"] = board.name
	return board



func spawn_Misc(info : Dictionary) -> Spatial:
	var misc
	
	match info["name"]:
		"Container":
			misc = container_pl.instance()
			misc.set_name("container"+str(container_index))
			container_index += 1
			if info.has("spawned_name") and info["spawned_name"]:
				misc.set_name(info["spawned_name"])
			
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
					return misc 
			
			if not List.players[ownerid].has("name"):
				yield(get_tree().create_timer(0.1),"timeout")
				if not List.players[ownerid].has("name"):
					List.paths[misc.name] = misc.get_path()
					return misc
			var ownername = List.players[ownerid]["name"]
			var ownercolor = List.players[ownerid]["color"]
			misc.set_hand_owner(ownerid,ownername)
			misc.set_hand_color(ownercolor)
			misc.others_can_touch = info["others_can_touch"]
	
	
	if info.has("spawned_name") and info["spawned_name"]:
		misc.set_name(info["spawned_name"])
	
	List.paths[misc.name] = misc.get_path()
	
	
	if info.has("translation"):
		var tr = info["translation"] as Vector3
		tweenit(misc, Vector3(0,0,0), tr)
	else:
		tweenit(misc, Vector3(0,0,0), Vector3(0,1,0))
	
	return misc



func spawn_Card(info) -> Spatial:
	var crd : card
	var cname : String = info["name"]
	if not cname or cname.empty(): 
		push_error("name is not valid")
		return null
	
	var br_cards := [
		"item","resource",
		"exp_island_item","exp_island_resource",
		"exp_skill","exp_military"
		]
	
	if cname in br_cards:
		crd = br_card_pl.instance() as br_card
		if info.has("id"):
			crd.set_name(info["id"])
		else:
			crd.set_name(cname + str(br_cards_index))
			br_cards_index += 1
		
		crd.set_type(cname)
		crd.update_material()
	
	
	match cname:
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
	
	crd.set_type(cname)
	
	if info.has("spawned_name") and info["spawned_name"]:
		crd.set_name(info["spawned_name"])
	
	#spawn
	cards_folder.add_child(crd,true)
	List.paths[crd.name] = crd.get_path()
	
	if info.has("translation"):
		var tr = info["translation"]
		# no tween please
		crd.translation = tr
	else:
		tweenit(crd, Vector3(0,0,0), Vector3(0,1,0))
	
	
	crd.card_value = info["value"]
	if info.has("value_second"):
		crd.card_value_second = info["value_second"]
	
	crd.set_is_hidden(false)
	
	
	
	if info.has("is_in_container") and info["is_in_container"]:
		if info.has("in_container") and info["in_container"]:
			var con = Std.get_object(info["in_container"]) as container
			if not con or not is_instance_valid(con): return null
			con.add_card_to_container(crd)
	
	return crd



func spawn_Expansion(info) -> Spatial:
	var expansion = expansion_pl.instance()
	
	expansion.set_name(info["name"]+"_pack_"+str(expansion_index))
	
	expansion.expansion_name = info["name"]
	
	if info.has("value_second"):
		expansion.pack_second_value = info["value_second"]
	
	for ch in expansion.get_children():
		ch.name += str(expansion_index)
	
	expansion_index += 1
	
	
	if info.has("translation"):
		var tr = info["translation"] as Vector3
		assert(tr, "translation must be a valid Vector3")
		expansion.child_translation = tr
	
	get_node("/root/Main/cards").add_child(expansion,true)
	List.paths[expansion.name] = expansion.get_path()
	
	
	
	
	return expansion










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
