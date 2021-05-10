extends Spatial



export(Array,NodePath) var positions := []


var currently_moving := []

onready var state_manager = $state_manager
onready var player = $player
onready var others = $others
onready var cards = $cards

onready var resource_dispenser = $board/dispenser
onready var item_dispenser = $board/dispenser2



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	NetworkInterface.Main = self
	state_manager.player = player
	state_manager.others = others
	
	List.cards_folder = cards
	
	var my_mat = get_player_material(get_tree().get_network_unique_id())
	player.get_node("pointer").set_surface_material(0,my_mat)
	
	# FIXME remove spawning had directly, make it optional
	_spawn_hand(get_tree().get_network_unique_id())
	
	NetworkInterface.request_envs()



func _spawn_player(var pid):
	if pid == get_tree().get_network_unique_id(): return
	if get_node("others").has_node(str(pid)): return
	
	
	var plo = preload("res://scenes/otherPlayer.tscn").instance()
	plo.set_name(str(pid))
	plo.set_network_master(pid)
	
	
	
	var material = get_player_material(pid)
	plo.get_child(0).set_surface_material(0, material)
	
	others.add_child(plo)
	print("M: spawned player and hand, id:",pid)


func get_player_material(id) -> SpatialMaterial:
	var material = SpatialMaterial.new()
	material.albedo_color = List.players[id]["color"] 
	return material


func _spawn_hand(pid) -> void:
	var ph = preload("res://scenes/hand.tscn").instance()
	ph.set_name("hand"+str(pid))
	ph.set_network_master(pid)
	
	var p_rand = get_node(positions[pid%4 -1])
	var phand_rand = p_rand.get_child(0)
	var rand_hand_pos = p_rand.translation + phand_rand.translation
	ph.translation = rand_hand_pos
#	ph.translation = Std.get_global(hand_pos3d)
#	ph.rotation = hand_pos3d.rotation
	
	
	var mat = get_player_material(pid)
	ph.get_node("handMesh").set_surface_material(0, mat)
	
	ph.owner_name = List.players[pid]["name"]
	
	
	cards.add_child(ph)
	
	List.paths[ph.name] = ph.get_path()
	




func process_received_world_state(world_state) -> void:
	state_manager.process_received_world_state(world_state)







	"""
	here
	"""


