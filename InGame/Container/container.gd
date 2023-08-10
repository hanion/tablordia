extends Area
class_name container

var container_id : int = -1

export var can_stack := true
export var can_draw := true

export var is_mesh_visible := true

export var is_cards_hidden := true

export(int, "all", "resource", "item") var holds = 0 


export var can_make_cards_visible := true
export var can_make_cards_hidden := true


onready var col = $CollisionShape
onready var mes = $MeshInstance
onready var twen = $Tween
onready var rcm_manager = $rcm_manager

# holds card_data {"id":id,"name":name, "value":value, "value_second":value_second}
var data_inv := []

# holds card
var card_inv := []

var is_moving := false



func _ready():
	var player = get_node("/root/Main/player")
	player.connect("started_dragging",self,"on_started_dragging")
	player.connect("stopped_dragging",self,"on_stopped_dragging")
	
	col.shape = col.shape.duplicate(true)
	mes.visible = is_mesh_visible
	ask_for_data()


func _process(_delta):
	if not is_moving: return
	if card_inv.empty(): return
	card_inv.back().global_translation = global_translation + Vector3(0,0.1,0)
	moving_define_obj_state(card_inv.back())

func moving_define_obj_state(drgn) -> void:
	var state = {
		drgn.name:{
			"O": Std.get_global(drgn),
			"R": drgn.rotation
		}
	}
	NetworkInterface.collect_state(state)



func ask_for_data() -> void:
	if get_tree().is_network_server(): return
	NetworkInterface.request_container_data(name)



func add_data_to_container(card_data: Dictionary) -> void:
	if not card_data or card_data.empty(): return
	
	if not card_data.has("name"): return
	if not card_data.has("value"): return
	
	data_inv.append(card_data)
#	print("	c: ",name,": added data ", card_data)
	order_env()

func remove_data_from_container(card_data : Dictionary) -> void:
	if not card_data or card_data.empty(): return
	
	if data_inv.empty(): return
	if not data_inv.has(card_data): return
	
	data_inv.erase(card_data)
#	print("	c: ",name,": removed data ", card_data)
	order_env()



func add_card_to_container(crd : card) -> bool:
	if not can_stack: return false
	
	if not card_inv.empty():
		if card_inv.back() == crd:
			return false
	
	# change to one var called type
	if holds == 1:
		if not crd.is_resource: return false
	elif holds == 2:
		if not crd.is_item: return false
	
	crd.is_in_container = true
	crd.in_container = self
	
	card_inv.append(crd)
	order_env()
	
#	print("	c: ",name,": added crd ", crd.name)
	return true


func remove_card_from_container(crd : card) -> bool:
	prints("	removing from container ", crd.name, crd.is_in_container, card_inv.size())
	if not can_draw: return false
	if card_inv.empty(): return false
	
	crd.is_in_container = false
	crd.in_container = null
	
	card_inv.erase(crd)
	order_env()
	
	return true




func order_env() -> void:
	
	if data_inv.empty() and card_inv.empty(): return
	
	if card_inv.size() == 0:
		instanciate_new_card()
		return
	
	
	var up_card : card = card_inv.back()
	
	# removed card
	if not is_instance_valid(up_card): 
		card_inv.erase(up_card)
		instanciate_new_card()
		return
	
	if not up_card.is_in_container: return
	
	up_card.visible = true
	up_card.is_hidden = is_cards_hidden
	
	for i in range(0,card_inv.size()-1):
		var hidden_card:card = card_inv[i]
		if hidden_card and is_instance_valid(hidden_card):
			hidden_card.translation = global_translation + Vector3(0, -10.5, 0)
		
	tween_up_card(up_card)




func instanciate_new_card() -> void:
	
	# FIXME because we dont pop data,
	# client do not know the updated card count
	if not get_tree().is_network_server():
		ask_for_data()
		return
	
	var card_data : Dictionary = data_inv.pop_front()
	if not card_data or card_data.empty(): return
	
	assert(card_data.has("name"),         "this should never happen")
	assert(card_data.has("value"),        "this should never happen")
	assert(card_data.has("value_second"), "this should never happen")
	
	var info := {
			"name":            card_data["name"],
			"type":            "Card",
			"amount":          1,
			"value":           card_data["value"],
			"value_second":    card_data["value_second"],
			"is_in_container": true,
			"in_container":    name,
			"translation":     global_translation + Vector3(0, -0.5, 0),
			"no UMB":          true
	}
	
	if card_data.has("id"):
		info["id"] = card_data["id"]
#		print(" con adding with id ",info["id"])
	
	
	Spawner.request_spawn(info)


func tween_up_card(crd : card) -> void:
#	crd.translation = global_translation + Vector3(0, 0.1, 0)
	crd.set_collision_layer_bit(0,true)
	
	
	twen.stop_all()
	if crd.translation.y < 0.05:
		crd.translation = global_translation + Vector3(0, -0.5, 0)
		twen.interpolate_property(
			crd,
			"scale",
			Vector3(0.1, 0.1, 0.1),
			Vector3(1, 1, 1),
			Std.tween_duration*2,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN
			)
	
	twen.interpolate_property(
		crd,
		"translation",
		crd.translation,
		global_translation + Vector3(0, 0.1, 0),
		Std.tween_duration/2,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
		)
	
	if not twen or not is_instance_valid(twen): return
	twen.start()


func get_card_index(crd : card) -> int:
	return card_inv.find(crd) 



# called from player -> drag_start when moved self
# self is currently being dragged
func on_started_moving() -> void:
	if not card_inv or card_inv.empty(): return
	if not is_instance_valid(card_inv.back()): return
	card_inv.back().set_collision_layer_bit(0,false)
	is_moving = true
	set_process(true)


# called from player -> drag_stop when moved self
func on_stopped_moving() -> void:
	if not card_inv or card_inv.empty(): return
	if not is_instance_valid(card_inv.back()): return
#	yield(get_tree().create_timer(0.1),"timeout")
	card_inv.back().set_collision_layer_bit(0,true)
	is_moving = false
	set_process(false)


# called from player -> drag_start on any object
func on_started_dragging(it) -> void:
	if not can_draw:
		col.shape.extents.y = 0.16
	
	if not it is card: return
	
	if holds == 2 and not it.is_item: return
	elif holds == 1 and not it.is_resource: return
	
	col.shape.extents.y = 0.3
	col.shape.extents.x = 1
	col.shape.extents.z = 1.3


# called from player -> drag_stop on any object
func on_stopped_dragging() -> void:
	if can_draw:
		col.shape.extents.y = 0.02
	else:
		col.shape.extents.y = 0.16
	
	col.shape.extents.x = 0.75
	col.shape.extents.z = 1.05


### rcm manager ###
func prepare_rcm(popup:PopupMenu) -> void:
	rcm_manager.prepare_rcm(popup)
remote func rcms(a,b,c):
	rcm_manager.rcms(a,b,c)
