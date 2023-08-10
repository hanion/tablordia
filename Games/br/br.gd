extends StaticBody

func get_game_spawn_name() -> String:
	return "Board Royale"

export(Array,SpatialMaterial) var res_mats := []
export(Array,SpatialMaterial) var item_mats := []

onready var Main = get_parent().get_parent()

var init_br_on_ready : bool = true

const my_paths := {
	"board":"/root/Main/cards/br/board",
	
	"trash_container":"/root/Main/cards/br/trash_container",
	"trash_container2":"/root/Main/cards/br/trash_container2",
	
	"slot":"/root/Main/cards/br/slot",
	"slot2":"/root/Main/cards/br/slot2",
	"slot3":"/root/Main/cards/br/slot3",
	"slot4":"/root/Main/cards/br/slot4"
	}


func _ready() -> void:
	Main.br = self
	
	List.feed_my_paths(my_paths)
	
	
	if not init_br_on_ready: return
	if not get_tree().is_network_server(): return
	
	# resource dispenser
	var info := {
		"type":"Expansion",
		"name":"exp_island_resource",
		"translation":Vector3(3.17,0.046,-2.6)
		}
	Spawner.request_spawn(info)
	
	# item dispenser
	var info2 := {
		"type":"Expansion",
		"name":"exp_island_item",
		"translation":Vector3(-3.17,0.046, 2.6)
		}
	Spawner.request_spawn(info2)
	


func _exit_tree():
	List.remove_my_paths(my_paths)

