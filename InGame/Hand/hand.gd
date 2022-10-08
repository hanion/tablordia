extends Spatial

class_name hand

export var only_items := false
export var only_resources := false


export(int) var SQUEEZING_START = 10
export(float) var SQUEEZING_X_OFFSET = 0.35
export(bool) var SORT_BY_SECOND_VALUE = true
export(float) var ON_DRAG_EXTENTS = 0.3


export(float) var offsetx = 1.44
export(float) var offsety = 0.15
export(float) var offsetz = 0.0

export(float) var tween_duration = 0.2

export(float) var off_y = 0.25


onready var cards = get_parent()
onready var col = $handCol
onready var hand_mesh = $handMesh
onready var nametag = $nametag3d/Viewport/nametag

var inventory := []

var is_cards_hidden_to_others := true setget set_chtot
var is_cards_hidden_to_owner := false setget set_chtow
var others_can_touch := true

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
	mat.metallic = 0.0
	mat.metallic_specular = 0.0
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
	# index = where card should be inserted
	var index = find_index(difference.x)
	# move cards from index to one right
	var hole_in_list = cut_list(index)
	# add current card to opened index
	inventory[hole_in_list] = crd
	
	
	# keep the global position of card
	var global_pos = List.reparent_child(crd,self)
	
	crd.translation = Std.complex_rotate(global_pos - translation,rotation.y)
	crd.rotation_degrees = Vector3(0,0,0)
	
	# change cards hidden val
	if am_i_the_owner:
		set_card_hidden(crd,is_cards_hidden_to_owner)
	else:
		set_card_hidden(crd,is_cards_hidden_to_others)
	
	# do card specific actions
	if crd.has_method("added_to_hand"):
		crd.call_deferred("added_to_hand")
	
	resize_hand()

func remove_card_from_hand(var crd: card) -> void:
	
	crd.is_in_hand = false
	crd.in_hand = null
	
	
#	var difference = crd.translation - translation
#	difference = Std.complex_rotate(difference,rotation.y)
	# keep the global position of card
#	List.reparent_child(crd,cards)
	
#	crd.translation = Std.complex_rotate(global_pos - translation,rotation.y)
#	crd.rotation_degrees = Vector3(0,0,0)
	
	
	# cards are visible to everyone in global context
	set_card_hidden(crd,false)
	
	inventory.erase(crd)
#	# keep the global position of card
	var old_translation = to_global(crd.translation)
	
	List.reparent_child(crd,cards)
	resize_hand()
	crd.translation = old_translation
	crd.rotation.y = rotation.y
	
#	check_after_onemsec(crd,__a)
	
	if crd.has_method("removed_from_hand"):
		crd.call_deferred("removed_from_hand",self)
	
	



# checks if card is accidentally moved by user and puts it back to place
func check_after_onemsec(cd,ot):
	yield(get_tree().create_timer(0.05),"timeout")
	if cd.translation == ot: return
	
	cd.translation = ot

func order_inventory() -> void:
	# because positions are relative to hand
	# we need to find where is center of hand
	var half_of_handx = ( (inventory.size() - 1) * offsetx ) / 2
	
	for i in inventory.size():
		# position.x of (i)card relative to hand
		var posx = (i * offsetx) - half_of_handx
		var posy:float
		
		var kart = inventory[i]
		
		if is_squeezing:
			# (rotate) and (move in y) card slightly to make them not zfight
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
	# index = where card should be inserted
	var index = find_index(difference.x)
	# move cards from index to one right
	var hole_in_list = cut_list(index)
	# add current card to opened index
	inventory[hole_in_list] = crd
	
	resize_hand()

# resize mesh and collision shape
func resize_hand() -> void:
	var inv_size = (inventory.size())
	
	
	if inv_size > SQUEEZING_START:
		offsetx = SQUEEZING_X_OFFSET
		is_squeezing = true
	else:
		offsetx = 1.44
		is_squeezing = false
	
	
	# to not make it tiny when there is no card
	if inv_size == 0: inv_size = 0.5
	
	var siz = inv_size * offsetx + offsetx/6
	
	
	tweenit(col,"shape:extents:x",col.shape.extents.x,siz/2)
	tweenit(hand_mesh,"mesh:size:x",hand_mesh.mesh.size.x, siz)
	order_inventory()

# finds where(index) card should go 
func find_index(var relativex: float) -> int:
	var inv_size = inventory.size()
	
	# because positions are relative to hand
	# we need to find where is center of hand
	var half_of_handx = ( (inv_size - 1) * offsetx ) / 2
	
	
	for i in inv_size:
		# position of (i)cards left edge
		var posx = (i * offsetx) - half_of_handx - (1.44/2)
		
		# test to see if new card is further than posx(i)card
		if relativex > posx:
			# if its further than (i)card go to next card
			continue
		else:
			# if its not further than (i)card return this index
			# we are returning (i)cards index because this is gonna be new -
			# cards position and (i)card will be moved to next index
			return i
	
	# if its bigger than every card, its last
	return inv_size

# moves cards from index to one right and opens a hole(empty space) in list
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
		col.shape.extents.y = ON_DRAG_EXTENTS
	
	elif only_items and _a.is_item:
		col.shape.extents.y = ON_DRAG_EXTENTS
	
	elif not only_items and not only_resources:
		col.shape.extents.y = ON_DRAG_EXTENTS
	
	
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



func bubble_sort_hand() -> void:
	var arr:Array = inventory
	var n = len(arr)
	
	for i in range(n):
		for j in range(0, n-i-1):
			
			var objj = arr[j]
			var objjpo = arr[j+1]
			
			if objj.card_value > objjpo.card_value:
				arr[j] = objjpo
				arr[j+1] = objj
			
			elif objj.card_value == objjpo.card_value:
				if objj.card_value_second > objjpo.card_value_second:
					arr[j] = objjpo
					arr[j+1] = objj
	
	inventory = arr



func bubble_sort_hand_by_second() -> void:
	var arr:Array = inventory
	var n = len(arr)
	
	for i in range(n):
		for j in range(0, n-i-1):
			
			var objj = arr[j]
			var objjpo = arr[j+1]
			
			if objj.card_value_second > objjpo.card_value_second:
				arr[j] = objjpo
				arr[j+1] = objj
			
			elif objj.card_value_second == objjpo.card_value_second:
				if objj.card_value > objjpo.card_value:
					arr[j] = objjpo
					arr[j+1] = objj
	
	inventory = arr






############################## RCM ##############################
var cavt:PopupMenu
var __popup:PopupMenu
func prepare_rcm(popup:PopupMenu) -> void:
	__popup = popup
	popup.clear()
	
	prepare_cavt(popup)
	if inventory.size() > 1:
		popup.add_item("Shuffle hand",2)
		if not am_i_the_owner:
			popup.set_item_disabled(popup.get_item_index(2),true)
		
		popup.add_item("Sort hand",3)
		if not am_i_the_owner:
			popup.set_item_disabled(popup.get_item_index(3),true)
	
	
	popup.add_separator("")
	popup.add_item("Hand Settings",1)
	if not am_i_the_owner:
		popup.set_item_disabled(popup.get_item_index(1),true)
	
	
	

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



var sender_id
remote func rcms(a,b=-1,c=-1):
	sender_id = get_tree().get_rpc_sender_id()
	rcm_selected(a,b,c)

func rcm_selected(id, _index=-1, _text=-1) -> void:
	match id:
		1:
			_open_hans_settings()
		2:
			make_hand_collapse()
			shuffle_hand()
			order_inventory()
		3:
			if SORT_BY_SECOND_VALUE:
				bubble_sort_hand_by_second()
			else:
				bubble_sort_hand()
			order_inventory()
		
############################## RCM ##############################

var _hs:AcceptDialog
func _open_hans_settings() -> void:
	if not sender_id == get_tree().get_network_unique_id(): return
	_hs = RCM.open_hand_settings(self,"_on_hs_confirmed")

func _on_hs_confirmed() -> void:
	var squeeze_spacing := float(_hs.get_node("vb/squeeze_spacing/input").text)
	var squeeze_start := int(_hs.get_node("vb/squeeze_start/input").text)
	var sort_by_second_val = _hs.get_node("vb/sort_by_second_value").pressed
	
	if not squeeze_spacing == 0 and not squeeze_start == 0:
		rpc_config("set_hand_settings",MultiplayerAPI.RPC_MODE_REMOTESYNC)
		rpc("set_hand_settings",squeeze_spacing,squeeze_start,sort_by_second_val)
		
		_hs.disconnect("confirmed",self,"_on_hs_confirmed")
		RCM.close_hand_settings()

remote func set_hand_settings(sq_sp:float, sq_st:int, sbsv:bool) -> void:
	print(sq_sp,sq_st,sbsv)
	SQUEEZING_X_OFFSET = sq_sp
	SQUEEZING_START = sq_st
	SORT_BY_SECOND_VALUE = sbsv


