extends Node

onready var loader = $loader


var WORLD_STATE := {
	"id" : {
		"spawn_type":         "Card",
		"spawn_name":         "exp_skill",
		
		"name":               "exp_skill7",
		
		"has_instance":       true,
		"instance":           "instance_object_ref", # [Area2D:5674]
		
		"is_in_container":    true,
		"in_container":       "container_id", # "exp_container2"
		"in_container_index": "i of env[i]",
		
		"is_in_hand":         false,
		"in_hand":            "hand_id",
		"in_hand_index":      "i of env[i]",
		
		"owner_id":           "ownerid",
		
		"last_do_state":      { },
		"last_state":         { }
	}
}


func LOAD_STATE(WS : Dictionary) -> void:
	UMB.log(1,"STATE","Loading received World State...")
	WORLD_STATE = WS
	loader.LOAD_STATE(WS)


func update_card_state(crd : card) -> void:
	var card_state : Dictionary = {
		"spawn_type":         "Card",
		"spawn_name":         crd.get_type(),
		
		"name":               crd.name,
		
		"value":              crd.card_value,
		"value_second":       crd.card_value_second,
		
		"has_instance":       true,
		"instance":           crd, # [Area3D:5674]
		
		"is_in_container":    crd.is_in_container,
		"in_container":       crd.get_container_name(),
		"in_container_index": crd.get_container_index(),
		
		"is_in_hand":         crd.is_in_hand,
		"in_hand":            crd.get_hand_name(),
		"in_hand_index":      crd.get_hand_index(),
		
		"transform":          crd.transform
		
	}
	
#	var id = ID.get_id(crd)
#	WORLD_STATE[id] = card_state
	WORLD_STATE[crd.name] = card_state


func update_container_state(con : container) -> void:
	var container_state : Dictionary = {
		"spawn_type":         "Misc",
		"spawn_name":         "Container",
		
		"name":               con.name,
		
		"has_instance":       true,
		"instance":           con, # [Area3D:5674]
		
		"data_inv":           con.data_inv,
		"card_inv":           _get_card_inv_id_array(con.card_inv),
		
		"transform":          con.transform
	}
	
#	var id = ID.get_id(con)
#	WORLD_STATE[id] = container_state
	WORLD_STATE[con.name] = container_state


func update_hand_state(han : hand) -> void:
	var hand_state : Dictionary = {
		"spawn_type":         "Misc",
		"spawn_name":         "Hand",
		
		"name":               han.name,
		
		"has_instance":       true,
		"instance":           han, # [Area3D:5674]
		"owner_id":           han.owner_id,
		"owner_name":         han.owner_name,
		"others_can_touch":   han.others_can_touch,
		
		"card_inv":           _get_card_inv_id_array(han.inventory),
		
		"transform":          han.transform
	}
	
#	var id = ID.get_id(han)
#	WORLD_STATE[id] = hand_state
	WORLD_STATE[han.name] = hand_state



func update_game_state(gam : Spatial) -> void:
	var game_state : Dictionary = {
		"spawn_type":         "Game",
		"spawn_name":         gam.get_game_spawn_name(),
		"name":               gam.name,
		
		"transform":          gam.transform
		}
	
#	var id = ID.get_id(han)
#	WORLD_STATE[id] = hand_state
	WORLD_STATE[game_state["name"]] = game_state



func _get_card_inv_id_array(inv : Array) -> Array:
	var cards_ids_inv : Array = []
	for crd in inv:
		if not crd or not is_instance_valid(crd):
			inv.erase(crd)
			continue
#		cards_ids_inv.append(ID.get_card_id(crd))
		cards_ids_inv.append(crd.name)
	
	return cards_ids_inv


# id is currently the name of the object
# should always be unique
func set_last_state(id : String, state : Dictionary) -> void:
	if not WORLD_STATE.has(id): 
		push_error("STATE: id does not exist in world state ,id="+id)
		return
	
	WORLD_STATE[id]["last_state"] = state

func set_last_do_state(id : String, do_state : Dictionary) -> void:
	if not WORLD_STATE.has(id): 
		push_error("STATE: id does not exist in world state ,id="+id)
		return
	
	WORLD_STATE[id]["last_do_state"] = do_state



