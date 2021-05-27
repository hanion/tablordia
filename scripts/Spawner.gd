extends Spatial

const br_card_path = "res://scenes/br_card.tscn"
const br_board_path = "res://scenes/br/br.tscn"

const hand_path = "res://scenes/hand.tscn"

var cards_folder

var resource_index:int = 0
var item_index:int = 0
var hand_index:int = 0



func request_spawn(type,value,amount) -> void:
	NetworkInterface.request_spawn(type,value,amount)

func receive_requested_spawn(_ty,_va,_am) -> void:
	_spawn(_ty,_va,_am)

func _spawn(type,value,amount) -> void:
	if type == "resource" or type == "item":
		for _i in range(amount):
			spawn_brc(type,value)
	elif type == "misc":
		for _i in range(amount):
			spawn_misc(value)
	else:
		push_error("unknown type to spawn")


func spawn_brc(type,value) -> void:
	var brc = load(br_card_path).instance()
	var card_value 
	
	if type == "item":
		brc.set_name("item"+str(Spawner.item_index))
		Spawner.item_index += 1
		
		brc.is_item = true
	elif type == "resource":
		brc.set_name("resource"+str(Spawner.resource_index))
		Spawner.resource_index += 1
		
		brc.is_resource = true
	
	card_value = value
	brc.card_value = card_value
	brc.is_hidden = false
	
	brc.update_material()
	
	cards_folder.add_child(brc)
	List.paths[brc.name] = brc.get_path()
	
	tweenit(
		brc,
		Vector3(0,0.04,0),
		Vector3(0,1,0)
		)



func spawn_misc(val) -> void:
	match val:
		1:
			spawn_misc_br()
		2:
			spawn_misc_hand()



func spawn_misc_br() -> void:
	var br = load(br_board_path).instance()
	get_node("/root/Main").add_child(br)
	List.paths[br.name] = br.get_path()
	tweenit(
		br,
		Vector3(0,-0.1,0),
		Vector3(0,0.004,0)
		)


func spawn_misc_hand() -> void:
	var ph = preload(hand_path).instance()
	ph.set_name("hand"+str(hand_index))
	hand_index += 1
	
	ph.translation = Vector3(0,0.5,0)
	
#	var mat = get_player_material(pid)
#	if mat:
#		ph.get_node("handMesh").set_surface_material(0, mat)
#
#	ph.owner_id = pid
#	if List.players.has(pid) and List.players[pid].has("name"):
#		ph.owner_name = List.players[pid]["name"]
	
	
	cards_folder.add_child(ph)
	
	List.paths[ph.name] = ph.get_path()




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
