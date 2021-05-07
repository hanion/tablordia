extends Spatial

class_name hand

export var only_items := false
export var only_resources := true

export(float) var offsetx = 1.44
export(float) var offsety = 0.15
export(float) var offsetz = 0

export(float) var tween_duration = 0.2

export(float) var off_y = 0.25


onready var cards = get_parent()
onready var col = $handCol
onready var hand_mesh = $handMesh

var inventory := []
var owner_name: String


func _ready():
	col.shape = col.shape.duplicate(true)
	hand_mesh.mesh = hand_mesh.mesh.duplicate(true)
	
	var nmtg = get_node("nametag3d/Viewport/nametag")
	var nmtg2 = get_node("nametag3d2/Viewport/nametag")
	nmtg.text = owner_name
	nmtg2.text = owner_name
	nmtg.set("custom_colors/font_color", hand_mesh.get_surface_material(0).albedo_color)
	nmtg2.set("custom_colors/font_color", hand_mesh.get_surface_material(0).albedo_color)
	
	var player = get_node("../../player")
	player.connect("started_dragging",self,"on_started_dragging")
	player.connect("stopped_dragging",self,"on_stopped_dragging")



func add_card_to_hand(var crd: card, var pos: Vector3) -> void:
	crd.is_in_hand = true
	crd.in_hand = self
	
	set_resource_hidden(crd,true)
	
	var difference = pos - translation
	difference = Std.complex_rotate(difference,rotation.y)
	var index = find_index(difference.x)
	var hole_in_list = cut_list(index)
	inventory[hole_in_list] = crd
	
	var global_pos = List.reparent_child(crd,self)
	
	crd.translation = Std.complex_rotate(global_pos - translation,rotation.y)
	
	order_inventory()
	resize_hand()

func remove_card_from_hand(var crd: card) -> void:
	crd.is_in_hand = false
	crd.in_hand = null
	
	set_resource_hidden(crd,false)
	
	inventory.erase(crd)
	
	var old_translation = to_global(crd.translation)
#	print("in hand old pos: ",old_translation)
	
	List.reparent_child(crd,cards)
	
	crd.translation = old_translation
	check_after_onemsec(crd,old_translation)
	order_inventory()
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
		
		var kart = inventory[i]
		var init_pos = kart.translation
		var final_pos = Vector3(posx, offsety, offsetz)
		tweenit(kart, "translation", init_pos, final_pos)


func reorder_card(crd, pos:Vector3) -> void:
	inventory.erase(crd)
	
	
	var difference = pos - translation
	difference = Std.complex_rotate(difference,rotation.y)
	var index = find_index(difference.x)
	var hole_in_list = cut_list(index)
	inventory[hole_in_list] = crd
	
	order_inventory()
	resize_hand()


func resize_hand() -> void:
	var inv_size = (inventory.size())
	var siz = inv_size * offsetx + offsetx/4
	tweenit(col,"shape:extents:x",col.shape.extents.x,siz/2)
	tweenit(hand_mesh,"mesh:size:x",hand_mesh.mesh.size.x, siz)


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
	if only_items and _a is item:
		col.shape.extents.y = 0.16
	
	elif only_resources and _a is resource:
		col.shape.extents.y = 0.16
	
	for c in inventory:
		c.set_collision_layer_bit(0,false)

func on_stopped_dragging() -> void:
	col.shape.extents.y = 0.078
	for c in inventory:
		c.set_collision_layer_bit(0,true)





func set_resource_hidden(res,is_) -> void:
	var _name = "hand" + str(NetworkInterface.uid)
	if name == _name:
		is_ = false
	
	if res.is_resource:
		res.is_hidden = is_










