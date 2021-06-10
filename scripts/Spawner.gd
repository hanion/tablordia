extends Spatial

const br_card_path = "res://scenes/br_card.tscn"
const br_board_path = "res://scenes/br/br.tscn"

const hand_path = "res://scenes/hand.tscn"

var cards_folder

var resource_index:int = 0
var item_index:int = 0
var hand_index:int = 0



func request_spawn(info) -> void:
	NetworkInterface.request_spawn(info)

func receive_requested_spawn(info) -> void:
	_spawn(info)

func _spawn(info) -> void:
#	var info  = {
#		"type":type,
#		"amount":amount,
#		"value":val,
#		"owner_id":hand_owner_id,
#		"in_dispenser":self.name,
#		"translation":translation
#		}
	var type = info["type"]
	var amount = info["amount"]
	
	if type == "resource" or type == "item":
		for _i in range(amount):
			spawn_brc(info)
	elif type == "misc":
		for _i in range(amount):
			spawn_misc(info)
	else:
		push_error("unknown type to spawn")


func spawn_brc(info) -> void:
	var type = info["type"]
	var value = info["value"]
	
	var brc = load(br_card_path).instance() 
	
	if type == "item":
		brc.set_name("item"+str(Spawner.item_index))
		Spawner.item_index += 1
		
		brc.is_item = true
	elif type == "resource":
		brc.set_name("resource"+str(Spawner.resource_index))
		Spawner.resource_index += 1
		
		brc.is_resource = true
	
	
	brc.set_type(type)
	brc.card_value = value
	brc.is_hidden = false
	brc.update_material()
	
	
	
	#spawn
	cards_folder.add_child(brc)
	List.paths[brc.name] = brc.get_path()
	
	
	
	if info.has("in_dispenser"):
		brc.is_in_dispenser = true
		brc.in_dispenser = Std.get_object(info["in_dispenser"])
		brc.set_is_hidden(true)
	
	
	if info.has("translation"):
		tweenit(
			brc,
			info["translation"] - Vector3(0,0.1,0),
			info["translation"]
			)
	else:
		tweenit(
		brc,
		Vector3(0,0.04,0),
		Vector3(0,1,0)
		)
	
	
	



func spawn_misc(info) -> void:
	match info["value"]:
		1:
			spawn_misc_br()
		2:
			spawn_misc_hand(info)



func spawn_misc_br() -> void:
	var br = load(br_board_path).instance()
	get_node("/root/Main").add_child(br)
	List.paths[br.name] = br.get_path()
	tweenit(
		br,
		Vector3(0,-0.1,0),
		Vector3(0,0.004,0)
		)


func spawn_misc_hand(info) -> void:
	var ph = preload(hand_path).instance()
	ph.set_name("hand"+str(hand_index))
	hand_index += 1
	
	ph.translation = Vector3(0,0.5,0)
	
	
	cards_folder.add_child(ph)
	
	List.paths[ph.name] = ph.get_path()
	
	
	
	var ownerid = info["owner_id"]
	var ownername = List.players[ownerid]["name"]
	ph.set_hand_owner(ownerid,ownername)
	var ownercolor = List.players[ownerid]["color"]
	ph.set_hand_color(ownercolor)
	
#	var mat = get_player_material(pid)
#	if mat:
#		ph.get_node("handMesh").set_surface_material(0, mat)
#
#	ph.owner_id = pid
#	if List.players.has(pid) and List.players[pid].has("name"):
#		ph.owner_name = List.players[pid]["name"]
	




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
