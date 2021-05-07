extends Spatial


const item_path = "res://scenes/item.tscn"

var off_y = 0.04
onready var col = $CollisionShape


var item_index := 0
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


func _ready():
	yield(get_tree().create_timer(0.2),"timeout")
	shuffle_items()
#	spawn_item()

func shuffle_items() -> void:
	randomize()
	
	var siz = items.size()
	
	for i in range(siz):
		i = siz - i
		i -= 1
		
		if i == 0: continue
		
		var ran = randi() % i
		
		var first_val = items[i]
		var second_val = items[ran]
		
		items[i] = second_val
		items[ran] = first_val
	
#	print(items)


func spawn_item() -> void:
	var it = load(item_path).instance()
	get_parent().add_child(it)
	
	setup_item(it)
	
	it.set_name("item"+str(item_index))
	item_index += 1
	
	it.in_dispenser = self
	it.is_in_dispenser = true
	
	tweenit(
		it,
		translation - Vector3(0,off_y,0),
		translation + Vector3(0,off_y,0)
		)
#	it.translation = 
	
	List.paths[it.name] = it.get_path()

func tweenit(obj,first,final) -> void:
	$Tween.stop_all()
	$Tween.interpolate_property(
		obj,
		"translation",
		first,
		final,
		Std.tween_duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
		)
	$Tween.start()



func setup_item(it) -> void:
	var item_value
	if item_index > items.size()-1:
		print("dispenser: !!! out of array")
		push_error("Dispenser is emptied")
		
		item_value = items[item_index-items.size()]
	else:
		item_value = items[item_index]
	
	
	
	var base = 0
	if item_value > 29:
		base = 1
		item_value -= 30
	
	
	it.item_base = base
	it.item_value = item_value
	
#	it.change_mat(base)
#	it.change_item(item_value)



func notify() -> void:
	spawn_item()


func set_received_inv(inv) -> void:
	items = inv
	spawn_item()
