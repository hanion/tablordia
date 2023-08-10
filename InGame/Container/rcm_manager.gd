extends Node
# containers rcm manager
# to keep container script cleaner


export var DRAWING_DELAY := 0.3

onready var parent : container = get_parent()


func shuffle_container() -> void:
	get_child(0).shuffle_container(parent)
	


############################## RCM ##############################
var _wa
var _jd
var sender_id := 0
func prepare_rcm(popup:PopupMenu) -> void:
	popup.clear()
	var card_number = parent.card_inv.size() + parent.data_inv.size()
	if card_number > 0:
		var txt = "Has "+str(card_number)+" card"
		if card_number > 1: txt += "s"
		popup.add_item(txt,77)
		popup.set_item_disabled(popup.get_item_index(77),true)
		popup.add_separator()
	
	
	if parent.can_make_cards_hidden and parent.can_make_cards_visible:
		popup.add_item("Make cards visible",2)
		popup.add_item("Make cards hidden",3)
	
	
	if card_number > 0:
		popup.add_item("Draw",4)
	
	# FIXME make a shuffle that WORKS
#	if card_number > 1:
#		popup.add_item("Shuffle",1)
	
	
	if card_number > 0:
		popup.add_item("Join",5)
	
	popup.add_item("! Delete !",8)
	

func rcms(a,b,c):
	sender_id = get_tree().get_rpc_sender_id()
	rcm_selected(a,b,c)

func rcm_selected(id,_index,_text) -> void:
	match id:
		1:
			# TODO create a shuffle function for container
			shuffle_container()
			parent.order_env()
		2:
			parent.is_cards_hidden = false
			parent.order_env()
		3:
			parent.is_cards_hidden = true
			parent.order_env()
		4:
			open_wa_panel()
		5:
			open_jd_panel()
		
		8:
			if not sender_id == get_tree().get_network_unique_id(): return
			RCM.open_confirm_remove_object(self, "_on_confirm_remove_object", parent.name)
			
			


func open_wa_panel() -> void:
	if not sender_id == get_tree().get_network_unique_id(): return
	var _sigto := {"target":self,"method":"_on_wa_confirmed"}
	_wa = RCM.open_wa(_sigto,"Draw Cards From Container","Drawing amount:")



func _on_wa_confirmed() -> void:
	var amo = int(  _wa.get_node("vbc/period/LineEdit").text  )
	
	if not amo == 0:
		
		rpc_config("request_draw_cards",MultiplayerAPI.RPC_MODE_REMOTESYNC)
		rpc("request_draw_cards",amo)
		_wa.disconnect("confirmed",self,"_on_wa_confirmed")
		RCM.close_wa()



func open_jd_panel() -> void:
	if not sender_id == get_tree().get_network_unique_id(): return
	var _sigto := {"target":self,"method":"_on_jd_confirmed"}
	_jd = RCM.open_jd(_sigto)



func _on_jd_confirmed() -> void:
	var _jd_input = _jd.get_node_or_null("vbc/period/LineEdit")
	if not _jd_input or not is_instance_valid(_jd_input): return
	
	var container_name : String = _jd_input.text
	if container_name == "" or container_name == null or container_name.empty(): return

	rpc_config("request_join_containers",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rpc("request_join_containers",container_name)
	_jd.disconnect("confirmed",self,"_on_jd_confirmed")
	RCM.close_jd()


############################## RCM ##############################
var requester_hand : hand
var drawing_amount : int = 0
var cards_drawn := 0


remote func request_draw_cards(amoun) -> void:
	draw_cards(amoun)


func draw_cards(amo) -> void:
	requester_hand = __find_requester_hand()
	if not requester_hand or not is_instance_valid(requester_hand):
		UMB.log(2,parent.name,"Couldn't find the requester hand, returning")
		return
	
	drawing_amount = amo
	cards_drawn = 0
	

	for i in drawing_amount:
		draw_card()
		yield(get_tree().create_timer(DRAWING_DELAY),"timeout")
		if parent.card_inv.size() == 0:
			yield(get_tree().create_timer(DRAWING_DELAY),"timeout")
			draw_card()
			if parent.card_inv.size() == 0:
				UMB.log(1,parent.name,"Not enough cards in container to draw.\nDrawn " + str(cards_drawn) + " cards.")
			return
		


func draw_card() -> void:
	if cards_drawn > drawing_amount: return
	if parent.card_inv.size() == 0: return
	
	
	var cur_card : card = parent.card_inv.back()
	var _res = parent.remove_card_from_container(cur_card)
	
	requester_hand.add_card_to_hand(cur_card,Vector3(9999,9999,9999))
	
	
	cards_drawn += 1
	
#	if drawing_amount == cards_drawn:
#		UMB.log(1,name,"Drawn " + str(cards_drawn) + " cards.")
#		print(name,": Drawn ",cards_drawn," cards.")




func __find_requester_hand() -> hand:
	for h in get_tree().get_nodes_in_group("hand"):
		if h.owner_id == sender_id:
			return h
	return null



# FIXME joining containers is a bit different
### Join Containers
remote func request_join_containers(container_name) -> void:
	join_containers(container_name)

func join_containers(container_name) -> void:
	var container_to_join = __find_container_by_name(container_name) as container
	if not is_instance_valid(container_to_join):
		UMB.log(2,parent.name,"Couldn't find the container to join, returning")
		return
	
	
	
	# data
	var all_datas := parent.data_inv.duplicate(true)
	parent.data_inv.clear()
	for card_data in all_datas:
		container_to_join.add_data_to_container(card_data)
	
	# cards
	var all_cards := parent.card_inv.duplicate(true)
	parent.card_inv.clear()
	for crd in all_cards:
		container_to_join.add_card_to_container(crd)
	
	
	
	yield(get_tree().create_timer(0.3),"timeout")
	container_to_join.order_env()
	parent.order_env()
	UMB.log(1,parent.name,"Joined container to " + str(container_name) + ".")
	



func __find_container_by_name(container_name) -> container:
	if not List.paths.has(container_name): return null
	
	var container_by_name = get_node_or_null(List.paths[container_name])
	
	return container_by_name
	


func _on_confirm_remove_object(object_name,popup):
	if popup.is_connected("confirmed",self,"_on_confirm_remove_object"):
		popup.disconnect("confirmed",self,"_on_confirm_remove_object")
	Remover.remote_remove_objects(object_name)

