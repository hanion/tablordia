extends Spatial

export(Array,SpatialMaterial) var res_mats := []
export(Array,SpatialMaterial) var item_mats := []

onready var Main = get_parent()

const my_paths := {
	"board":"/root/Main/br/board",
	
#	"dispenser":"/root/Main/br/dispenser",
#	"dispenser2":"/root/Main/br/dispenser2",
#	"trash":"/root/Main/br/trash",
#	"trash2":"/root/Main/br/trash2",
	"trash_deck":"/root/Main/br/trash_deck",
	"trash_deck2":"/root/Main/br/trash_deck2",
	
	"slot":"/root/Main/br/slot",
	"slot2":"/root/Main/br/slot2",
	"slot3":"/root/Main/br/slot3",
	"slot4":"/root/Main/br/slot4"
	}


func _ready() -> void:
	Main.br = self
	
	List.feed_my_paths(my_paths)
	
	
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

