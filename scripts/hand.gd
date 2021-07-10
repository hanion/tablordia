extends Spatial

class_name hand

export var only_items := false
export var only_resources := false
export(int) var SQUEEZING_START = 10
export(float) var SQUEEZING_X_OFFSET = 0.9

export(float) var offsetx = 1.44
export(float) var offsety = 0.15
export(float) var offsetz = 0

export(float) var tween_duration = 0.2

export(float) var off_y = 0.25


onready var cards = get_parent()
onready var col = $handCol
onready var hand_mesh = $handMesh
onready var nametag = $nametag3d/Viewport/nametag

var inventory := []

var is_cards_hidden_to_others := true setget set_chtot
var is_cards_hidden_to_owner := false setget set_chtow

var owner_name: String
var owner_id: int
var am_i_the_owner:bool = false

var is_squeezing := false


func _ready():
	col.shape = col.shape.duplicate(true)
	hand_mesh.mesh = hand_mesh.mesh.duplicate(true)
	
	var player = get_node("../../player")
	player.connect("started_dragging",self,"on_started_dragging")
	player.connect("stopped_dragging",self,"on_stopped_dragging")


func set_hand_color(color) -> void:
	nametag.set("custom_colors/font_color", color)
	
	var mat = SpatialMaterial.new()
	mat.set_albedo(color)
	hand_mesh.set_surface_material(0,mat)


func set_hand_owner(_owner_id, _owner_name) -> void:
	owner_id = _owner_id
	owner_name = _owner_name
	nametag.text = owner_name
	
	am_i_the_owner = (get_tree().get_network_unique_id() == owner_id)





func add_card_to_hand(var crd: card, var pos: Vector3) -> void:
	crd.is_in_hand = true
	crd.in_hand = self
	
	var difference = pos - translation
	difference = Std.complex_rotate(difference,rotation.y)
	var index = find_index(difference.x)
	var hole_in_list = cut_list(index)
	inventory[hole_in_list] = crd
	
	var global_pos = List.reparent_child(crd,self)
	
	crd.translation = Std.complex_rotate(global_pos - translation,rotation.y)
	crd.rotation_degrees = Vector3(0,0,0)
	
	set_card_hidden(crd,is_cards_hidden_to_others)
	if am_i_the_owner:
		set_card_hidden(crd,is_cards_hidden_to_owner)
	
	
	resize_hand()

func remove_card_from_hand(var crd: card) -> void:
	crd.is_in_hand = false
	crd.in_hand = null
	
	set_card_hidden(crd,false)
	
	inventory.erase(crd)
	
	var old_translation = to_global(crd.translation)
#	print("in hand old pos: ",old_translation)
	
	List.reparent_child(crd,cards)
	
	crd.translation = old_translation
	crd.rotation = rotation
	check_after_onemsec(crd,old_translation)
	resize_hand()

func check_after_onemsec(cd,ot):
	yield(get_tree().create_timer(0.05),"timeout")
	if cd.translation == ot: return
	
	cd.translation = ot
#	check_after_onesec(cd,ot)

func order_inventory() -> void:
	var half_of_handx = ( (inventory.size() - 1) * offsetx ) / 2
	
	for i in inventory.size():
		var posx = (i * offsetx) - half_of_handx
		var posy:float
		
		var kart = inventory[i]
		
		if is_squeezing:
			kart.rotation_degrees = Vector3(0,0,-0.2)
			posy = ((i+1)*1.01 - 1)/400
		else:
			kart.rotation_degrees = Vector3.ZERO
			posy = 0
		
		
		var init_pos = kart.translation
		var final_pos = Vector3(posx, offsety +posy, offsetz)
		tweenit(kart, "translation", init_pos, final_pos)


func reorder_card(crd, pos:Vector3) -> void:
	inventory.erase(crd)
	
	
	var difference = pos - translation
	difference = Std.complex_rotate(difference,rotation.y)
	var index = find_index(difference.x)
	var hole_in_list = cut_list(index)
	inventory[hole_in_list] = crd
	
	resize_hand()


func resize_hand() -> void:
	var inv_size = (inventory.size())
	
	
	if inv_size > SQUEEZING_START:
		offsetx = SQUEEZING_X_OFFSET
		is_squeezing = true
	else:
		offsetx = 1.44
		is_squeezing = false
	
	
	if inv_size == 0: inv_size = 0.5
	
	var siz = inv_size * offsetx + offsetx/6
	tweenit(col,"shape:extents:x",col.shape.extents.x,siz/2)
	tweenit(hand_mesh,"mesh:size:x",hand_mesh.mesh.size.x, siz)
	order_inventory()


func find_index(var relativex: float) -> int:
	var inv_size = inventory.size()
	
	var half_of_handx = ( (inv_size - 1) * offsetx ) / 2
	
	
	
	for i in inv_size:
		var posx = (i * offsetx) - half_of_handx
		
		if relativex > posx:
			continue
		else:
			return i
	
	return inv_size


func cut_list(var index: int) -> int:
	var inv_size = inventory.size()
	inventory.append(null)
	
	for i in inv_size:
		i = inv_size - i
		i -= 1
		
		if i < index:
			continue
		else:
			var this = inventory[i]
			inventory[i+1] = this
	
	return index




func tweenit(obj: Object, prop: String, init, final, dur=tween_duration) -> void:
	$Tween.interpolate_property(
			obj,
			prop,
			init,
			final,
			dur,
			Tween.TRANS_SINE,
			Tween.EASE_OUT
		)
	$Tween.start()




func on_started_dragging(_a) -> void:
	if _a == self:
		for c in inventory:
			c.set_collision_layer_bit(0,false)
	
	if not _a is card: return
	_a = _a as card
	
	if only_resources and _a.is_resource:
		col.shape.extents.y = 0.5
	
	elif only_items and _a.is_item:
		col.shape.extents.y = 0.5
	
	elif not only_items and not only_resources:
		col.shape.extents.y = 0.5
	
	
	for c in inventory:
		c.set_collision_layer_bit(0,false)

func on_stopped_dragging() -> void:
	col.shape.extents.y = 0.07
	for c in inventory:
		c.set_collision_layer_bit(0,true)





func set_card_hidden(res,is_) -> void:
	res.set_is_hidden(is_)



func set_cards_hidden(boo:bool) -> void:
	for crd in inventory:
		crd.set_is_hidden(boo)




func set_chtot(ih) -> void:
	is_cards_hidden_to_others = ih
	rpc_config("__schtot",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rpc("__schtot",ih)
remote func __schtot(_ih) -> void:
	is_cards_hidden_to_others = _ih

func set_chtow(ih) -> void:
	is_cards_hidden_to_owner = ih
	rpc_config("__schtow",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rpc("__schtow",ih)
remote func __schtow(_ih) -> void:
	is_cards_hidden_to_owner = _ih






func make_hand_collapse() -> void:
	for c in inventory:
		c.translation = Vector3(0,offsety,0)

func shuffle_hand() -> void:
	var dict := inventory
	if not get_tree().is_network_server(): return
	
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
	
	inventory = dict
	send_deck_to_others()


func send_deck_to_others() -> void:
#	print("sending deck to others")
	var named_deck := []
	for c in inventory:
		named_deck.append(c.name)
	NetworkInterface.send_deck_to_others(named_deck,self.name)
func receive_deck_from_server(named_deck) -> void:
#	print(self.name,": received named deck from server",named_deck)
	inventory.clear()
	for nc in named_deck:
		var crd = Std.get_object(nc)
		inventory.append(crd)
	
	order_inventory()




############################## RCM ##############################
var cavt:PopupMenu
func prepare_rcm(popup:PopupMenu) -> void:
	popup.clear()
	
	prepare_cavt(popup)
	
	popup.add_item("Shuffle hand",2)
	if not am_i_the_owner:
		popup.set_item_disabled(popup.get_item_index(2),true)
	
	popup.add_separator("")
	
	popup.add_item("Hand Settings",1)
	
	

func prepare_cavt(popup) -> void:
	cavt = RCM.get_a_submenu(popup,self.name+"cavt") as PopupMenu
	
	cavt.add_check_item("owner (me)" if am_i_the_owner else "owner",11)
	cavt.add_check_item("others",12)
	
	var index_11 = cavt.get_item_index(11)
	var index_12 = cavt.get_item_index(12)
	
	cavt.set_item_checked(index_11, not is_cards_hidden_to_owner)
	cavt.set_item_checked(index_12, not is_cards_hidden_to_others)
	
	if not am_i_the_owner:
		cavt.set_item_disabled(index_11,true)
		cavt.set_item_disabled(index_12,true)
	
	
	popup.add_submenu_item("Cards are visible to", self.name+"cavt")
	
	cavt.hide_on_checkable_item_selection = false
	if not cavt.is_connected("id_pressed",self,"_on_cavt_pressed"):
		var _er = cavt.connect("id_pressed",self,"_on_cavt_pressed")


func _on_cavt_pressed(id) -> void:
	if not am_i_the_owner: return
	
	var idx = cavt.get_item_index(id)
	var boo = (not cavt.is_item_checked(idx))
	cavt.set_item_checked(idx, boo)
	
	match id:
		11:
			set_chtow(not boo)
#			is_cards_hidden_to_owner = not boo
			set_cards_hidden(not boo)
		12:
#			is_cards_hidden_to_others = not boo
			set_chtot(not boo)
			
			rpc_config("_make_cards_hidden",MultiplayerAPI.RPC_MODE_REMOTESYNC)
			rpc("_make_cards_hidden",not boo)


remote func _make_cards_hidden(bo) -> void:
	if not get_tree().get_network_unique_id() == get_tree().get_rpc_sender_id():
		set_cards_hidden(bo)




remote func rcms(a,b=-1,c=-1):
	rcm_selected(a,b,c)

func rcm_selected(id, _index=-1, _text=-1) -> void:
	match id:
		1:
			print("TODO: make hand settings ui in rcm and open from here")
		2:
			make_hand_collapse()
			shuffle_hand()
			order_inventory()
		
############################## RCM ##############################




