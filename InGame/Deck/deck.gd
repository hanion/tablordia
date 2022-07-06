extends Area
class_name deck

signal removed_card_from_deck
signal added_card_to_deck


export var DRAWING_DELAY := 0.3

export var can_stack := true
export var can_draw := true
export var make_scale_effect := true
export var is_mesh_visible := true
export var is_cards_hidden := true
export var only_resources := false
export var only_items := false

export var custom_offset := 0.1


export var can_make_cards_visible := true
export var can_make_cards_hidden := true

var env := []

onready var old_pos = $old_card_pos
onready var col = $CollisionShape
onready var mes = $MeshInstance
onready var tween = $Tween

var visible_card : card

var player
func _ready():
	col.shape = col.shape.duplicate(true)
	player = get_node("/root/Main/player")
	player.connect("started_dragging",self,"on_started_dragging")
	player.connect("stopped_dragging",self,"on_stopped_dragging")


# called when dragging or received state
func set_new_visible_card_translation() -> void:
	if not visible_card: return
	visible_card.translation = Vector3(0, custom_offset ,0) + translation


func add_to_deck(what: card, bypass_can_stack_check:= false,should_check:=true) -> void:
	if not bypass_can_stack_check and not can_stack: return
	
	if not env.empty():
		if env.back() == what: return
	
	if only_items:
		if not what.is_item: return
	elif only_resources:
		if not what.is_resource: return
	
	what.is_in_deck = true
	what.in_deck = self
	
	env.append(what)
	
	
	what.translation = Vector3(0, custom_offset ,0)
	what.rotation = Vector3(0,0,0)
#	List.reparent_child(what,self)
	
	emit_signal("added_card_to_deck")
	
	order_env()
	if should_check:
		check_after_onesec()


func remove_from_deck(what: card) -> void:
	if not can_draw: return
	
	if env.empty(): return
	if not env.back() == what: return
	
	visible_card = null
	
	what.is_in_deck = false
	what.in_deck = null
	
	env.erase(what)
	
	
#	var old_translation = to_global(what.translation)
#	List.reparent_child(what,get_parent())
#	what.translation = old_translation
#	what.rotation = rotation
	
	what.set_is_hidden(false)
#
	emit_signal("removed_card_from_deck")
	
	order_env()


func order_env() -> void:
	if env.empty(): return
	
	for crd in env:
		crd.translation = old_pos.translation
		crd.scale = Vector3(1,1,1)
	
	var up_card = env.back()
	if name.begins_with("uno_draw_deck") or name.begins_with("doc"):
		yield(get_tree().create_timer(0.2),"timeout")
		if not up_card == env.back(): 
			up_card.visible = false
			return
	
	visible_card = up_card
	up_card.visible = true
	up_card.set_is_hidden(is_cards_hidden)
	tween_up_card(up_card)


func tween_up_card(obj:Spatial) -> void:
	print("	¨tweenup ",obj.name)
	tween.stop_all()
	if make_scale_effect:
		var old_scale = obj.scale
		tween.interpolate_property(
		obj,
		"scale",
		Vector3(0,0,0),
		old_scale,
		Std.tween_duration*2,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
		)
	
	obj.translation = translation + Vector3(0,-2*custom_offset,0)
	tween.interpolate_property(
		obj,
		"translation",
		obj.translation,
		translation+Vector3(0, custom_offset ,0),
		Std.tween_duration/2.0,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
		)
	tween.start()



var _is_player_dragging := false
func on_started_dragging(it) -> void:
	if it == self:
		for c in env:
			c.set_collision_layer_bit(0,false)
	
	if not can_draw:
		col.shape.extents.y = 0.16
	
	if not it is card: return
	if only_items and it.is_item:
		col.shape.extents.y = 0.16
	elif only_resources and it.is_resource:
		col.shape.extents.y = 0.16
	elif not only_items and not only_resources:
		col.shape.extents.y = 0.16
	
	_is_player_dragging = true

func on_stopped_dragging() -> void:
	
	if not can_draw:
		col.shape.extents.y = 0.16
	else:
		col.shape.extents.y = 0.02
	
	if not env.empty():
		for c in env:
			c.set_collision_layer_bit(0,true)
	
	_is_player_dragging = false




func check_after_onesec() -> void:
	yield(get_tree().create_timer(0.1),"timeout")
	if not env: return
	if not env.back().is_in_deck: return
	if not env.back().in_deck == self: return
	if env.back().translation == translation+Vector3(0, custom_offset ,0): return
	
	if _is_player_dragging: return
	
	env.back().translation = translation+Vector3(0, custom_offset ,0)
#	env.is_in_slot = true
#	env.in_slot = self
	
	print("checked deck")
	check_after_onesec()





func shuffle(dict:Array) -> void:
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
	
	send_deck_to_others()



func send_deck_to_others() -> void:
	print("sending deck to others")
	var named_deck := []
	for c in env:
		named_deck.append(c.name)
	NetworkInterface.send_deck_to_others(named_deck,self.name)
func receive_deck_from_server(named_deck) -> void:
	print(self.name,": received named deck from server",named_deck)
	env.clear()
	for nc in named_deck:
		var crd = Std.get_object(nc)
		env.append(crd)
	
	order_env()


############################## RCM ##############################
var _wa
var sender_id := 0
func prepare_rcm(popup:PopupMenu) -> void:
	popup.clear()
	if env.size() > 0:
		var txt = "Has "+str(env.size())+" card"
		if env.size() > 1: txt += "s"
		popup.add_item(txt,77)
		popup.set_item_disabled(popup.get_item_index(77),true)
		popup.add_separator()
	
	
	if can_make_cards_hidden and can_make_cards_visible:
		popup.add_item("Make cards visible",2)
		popup.add_item("Make cards hidden",3)
	
	
	if env.size() > 0:
		popup.add_item("Draw",4)
	
	if env.size() > 1:
		popup.add_item("Shuffle Deck",1)


remote func rcms(a,b,c):
	sender_id = get_tree().get_rpc_sender_id()
	rcm_selected(a,b,c)

func rcm_selected(id,_index,_text) -> void:
	match id:
		1:
			shuffle(env)
			order_env()
		2:
			is_cards_hidden = false
			order_env()
		3:
			is_cards_hidden = true
			order_env()
		4:
			open_wa_panel()
			
			


func open_wa_panel() -> void:
	if not sender_id == get_tree().get_network_unique_id(): return
	var _sigto := {"target":self,"method":"_on_wa_confirmed"}
	_wa = RCM.open_wa(_sigto,"Draw Cards From Deck","Drawing amount:")



func _on_wa_confirmed() -> void:
	var amo = int(  _wa.get_node("vbc/period/LineEdit").text  )
	
	if not amo == 0:
		
		rpc_config("request_draw_cards",MultiplayerAPI.RPC_MODE_REMOTESYNC)
		rpc("request_draw_cards",amo)
#		draw_cards(amo)
		_wa.disconnect("confirmed",self,"_on_wa_confirmed")
		RCM.close_wa()


############################## RCM ##############################
var requester_hand : hand
var drawing_amount : int = 0
var cards_drawn := 0





remote func request_draw_cards(amoun) -> void:
	draw_cards(amoun)

func draw_cards(amo) -> void:
	requester_hand = __find_requester_hand()
	if requester_hand == null:
		UMB.log(2,name,"Couldn't find the requester hand, returning")
#		print(name,": Couldn't find the requester hand, returning")
		return
	drawing_amount = amo
	cards_drawn = 0
	

	for i in drawing_amount:
		yield(get_tree().create_timer(DRAWING_DELAY),"timeout")
		draw_card()
		if env.size() == 0:
			UMB.log(1,name,"Not enough cards in deck to draw.")
			UMB.log(1,name,"Drawn " + str(cards_drawn) + " cards.")
			return
		


func draw_card() -> void:
	if cards_drawn > drawing_amount: return
	if env.size() == 0: return
	
	
	var cur_card = env.back()
	remove_from_deck(cur_card)
	requester_hand.add_card_to_hand(cur_card,Vector3(9999,9999,9999))
	
	
	cards_drawn += 1
	
	if drawing_amount == cards_drawn:
		UMB.log(1,name,"Drawn " + str(cards_drawn) + " cards.")
#		print(name,": Drawn ",cards_drawn," cards.")




func __find_requester_hand() -> hand:
	for h in get_tree().get_nodes_in_group("hand"):
		if h.owner_id == sender_id:
#			print(name,": Found requester hand")
			return h
#	UMB.log(2,name,"Couldn't find the requester hand")
#	print(name,": Couldn't find the requester hand")
	return null

