extends Area
const br_card_path = "res://scenes/br_card.tscn"

export(String, "resource", "item") var dispense


var off_y = 0.04
onready var col = $CollisionShape
onready var tween = $Tween

var env := []


var items := [
	1,1,2,3,3,4,5,5,
	6,7,7,8,8,9,10,11,
	12,13,14,15,16,16,17,17,
	17,18,18,19,19,20,20,20,
	20,20,20,20,20,20,20,20,
	20,20,20,20,30,30,31,31,
	39,38,37,36,35,34,33,32,
	47,46,45,44,43,42,41,40,
	53,52,51,50,49,48, 55,54,
	63,62,61,60,59,58,57,56,
	]


func create_inventory() -> void:
	if dispense == "item":
		shuffle(items)
	elif dispense == "resource":
		create_env()
		shuffle(env)


func create_env():
	for _a in range(30):
		env.append(1)
		env.append(2)
		env.append(3)
		env.append(4)
	for _i in range(20):
		env.append(5)


func shuffle(dict:Array) -> void:
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



func spawn_brc() -> void:
	var brc = load(br_card_path).instance()
	
	brc.is_in_dispenser = true
	brc.in_dispenser = self
	
	
	
	if dispense == "item":
		brc.set_name("item"+str(Spawner.item_index))
		Spawner.item_index += 1
	elif dispense == "resource":
		brc.set_name(dispense+str(Spawner.resource_index))
		Spawner.resource_index += 1
	
	
	setup_brc(brc)
	
	Spawner.cards_folder.add_child(brc)
	List.paths[brc.name] = brc.get_path()
	
	tweenit(
		brc,
		translation - Vector3(0,off_y,0),
		translation + Vector3(0,off_y,0)
		)



func setup_brc(brc) -> void:
	var obj_index
	var objs_array
	
	if dispense == "item":
		obj_index = Spawner.item_index
		objs_array = items
		
	elif dispense == "resource":
		obj_index = Spawner.resource_index
		objs_array = env
	
	brc.set_type(dispense)
	
	var card_value
	
	if obj_index > objs_array.size()-1:
		card_value = objs_array[obj_index-objs_array.size()]
	else:
		card_value = objs_array[obj_index]
	
	brc.card_value = card_value
	
	# set back material
	var mat: SpatialMaterial 
	if brc.is_item:
		mat = brc.item_mats[0].duplicate(true)
		mat.set_uv1_offset(brc.items[0][0]) # back
	elif brc.is_resource:
		mat = brc.res_mats[0].duplicate(true) # back
	
	brc.set_material(mat)



func notify() -> void:
	spawn_brc()



func set_received_inv(inv) -> void:
	if dispense == "item":
		items = inv
	else:
		env = inv
	spawn_brc()



func tweenit(obj: Spatial, first, final) -> void:
	tween.stop_all()
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
