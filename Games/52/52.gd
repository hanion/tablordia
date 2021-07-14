extends Spatial


const my_paths := {
	"iskambil":"/root/Main/52/iskambil"
	}

var deste := [] # Array[Vector2(card_value,card_value_second)]

onready var dek = $iskambil

func _ready() -> void:
	write_paths()
	
	yield(get_tree().create_timer(1),"timeout")
	
	if not get_tree().is_network_server(): return
	create_draw_deck()
	spawn_all_cards()


func write_paths() -> void:
	for objname in my_paths.keys():
		if List.paths.has(objname):
			push_error("List already has this objects path")
		List.paths[objname] = my_paths[objname]


func create_draw_deck() -> void:
	for sv in range(4):
		for v in range(1,14):
			deste.append(Vector2(v,sv))
	
	print("52: created deste ")
	
	deste = shuffle(deste)

func shuffle(dict:Array) -> Array:
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
	
	return dict





func spawn_all_cards() -> void:
	for c in deste:
		yield(get_tree().create_timer(0.001),"timeout")
		
		var info := {
			"type":"Card",
			"name":"52 Card",
			"amount":1,
			"value":c.x,
			"value_second":c.y,
			"in_deck":dek.name,
			"translation":(dek.translation + Vector3(0,-5,0)),
			"no UMB":true
		}
		
		Spawner.request_spawn(info)
	
	yield(get_tree().create_timer(0.01),"timeout")
	get_draw_deck_up()

func get_draw_deck_up() -> void:
	dek.translation = Vector3(0,0,0)
	var state = {
		dek.name:{
			"O": Std.get_global(dek),
			"R":dek.rotation
		}
	}
	
	NetworkInterface.collect_state(state)
