extends Area
class_name deck

signal removed_card_from_deck

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


func _ready():
	col.shape = col.shape.duplicate(true)
	var player = get_node("/root/Main/player")
	player.connect("started_dragging",self,"on_started_dragging")
	player.connect("stopped_dragging",self,"on_stopped_dragging")



func add_to_deck(what: card, bypass_can_stack_check:= false) -> void:
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
	List.reparent_child(what,self)
	
	order_env()
	check_after_onesec()


func remove_from_deck(what: card) -> void:
	if not can_draw: return
	
	if env.empty(): return
	if not env.back() == what: return
	
	
	what.is_in_deck = false
	what.in_deck = null
	
	env.erase(what)
	
	
	var old_translation = to_global(what.translation)
	List.reparent_child(what,get_parent())
	what.translation = old_translation
	what.rotation = rotation
	
	what.set_is_hidden(false)
	
	emit_signal("removed_card_from_deck")
	
	order_env()


func order_env() -> void:
	if env.empty(): return
	
	for crd in env:
		crd.translation = old_pos.translation
		crd.scale = Vector3(1,1,1)
	
	var up_card = env.back()
	up_card.set_is_hidden(is_cards_hidden)
	tween_up_card(up_card)
	

func tween_up_card(obj:Spatial) -> void:
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
	tween.interpolate_property(
		obj,
		"translation",
		obj.translation,
		Vector3(0, custom_offset ,0),
		Std.tween_duration,
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
	if env.back().translation == Vector3(0, custom_offset ,0): return
	
	if _is_player_dragging: return
	
	env.back().translation = Vector3(0, custom_offset ,0)
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
	var named_deck := []
	for c in env:
		named_deck.append(c.name)
	NetworkInterface.send_deck_to_others(named_deck,self.name)
func receive_deck_from_server(named_deck) -> void:
	print(self.name,": received named deck from server")
	env.clear()
	for nc in named_deck:
		var crd = Std.get_object(nc)
		env.append(crd)
	
	order_env()


############################## RCM ##############################
func prepare_rcm(popup:PopupMenu) -> void:
	popup.clear()
	if env.size() > 1:
		popup.add_item("Shuffle Deck",1)
	if env.size() > 0:
		
		popup.add_item("Make cards visible",2)
		if not can_make_cards_visible:
			popup.set_item_disabled(popup.get_item_index(2),true)
		
		popup.add_item("Make cards hidden",3)
		if not can_make_cards_hidden:
			popup.set_item_disabled(popup.get_item_index(3),true)



remote func rcms(a,b,c):
	rcm_selected(a,b,c)

func rcm_selected(id,_index,_text) -> void:
	if id == 1:
		shuffle(env)
		order_env()
	elif id == 2:
		is_cards_hidden = false
		order_env()
	elif id == 3:
		is_cards_hidden = true
		order_env()
		
############################## RCM ##############################


