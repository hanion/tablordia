extends Node

var next_card_id : int = 0

func create_new_card_id(crd : card) -> void:
	var new_id = next_card_id
	
	assert(not cards.has(new_id), "id already exists")
	cards[new_id] = crd
	crd.card_id = new_id
	next_card_id += 1

func create_new_con_id(con : container) -> void:
	var new_id = next_card_id
	
	assert(not cards.has(new_id), "id already exists")
	cards[new_id] = con
	con.container_id = new_id
	next_card_id += 1



func get_card_id(crd : card) -> int:
	if crd.card_id == -1:
		create_new_card_id(crd)
		return get_card_id(crd)
	
	return crd.card_id
	
func get_con_id(con : container) -> int:
	if con.container_id == -1:
		create_new_con_id(con)
		return get_con_id(con)
	
	return con.container_id





var cards : Dictionary = {
#	"id": "instance_id" # like [Array3D:5632] 
}

func get_card(id : int) -> card:
	if not cards.has(id): return null
	return cards[id]
