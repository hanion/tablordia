extends Spatial

export(Array,NodePath) var positions := []
const hand_path = "res://InGame/Hand/hand.tscn"

var currently_moving := []

onready var state_manager = $state_manager
onready var player = $player
onready var others = $others
onready var cards = $cards

var br

func _ready():
	NetworkInterface.Main = self
	Spawner.cards_folder = cards
	SettingsUI.initialize()
	RCM.player = player
	HUD.player = player
	HUD.spawn_panel = $CanvasLayer/SpawnPanel



func _spawn_player(var pid):
	if pid == get_tree().get_network_unique_id(): return
	if others.has_node(str(pid)): return
	
	
	var plo = preload("res://Systems/Small/otherPlayer.tscn").instance()
	plo.set_name(str(pid))
	plo.set_network_master(pid)
	
	
	
	var material = get_player_material(pid)
	plo.get_child(0).set_surface_material(0, material)
	
	others.add_child(plo)
	
	var col = List.players[pid]["color"].to_html()
	var nam = List.players[pid]["name"]
	var extxt = "[color=#"+col+"]" + nam
	UMB.log(1,"Main","Spawned " + extxt)


func get_player_material(id) -> SpatialMaterial:
	var material = SpatialMaterial.new()
	if not List.players.has(id): return null
	if not List.players[id].has("color"): return null
	material.albedo_color = List.players[id]["color"] 
	return material


func _spawn_hand(pid) -> void:
	var ph = preload(hand_path).instance()
	ph.set_name("hand"+str(pid))
	ph.set_network_master(pid)
	
	var p_rand = get_node(positions[pid%4 -1])
	var phand_rand = p_rand.get_child(0)
	var rand_hand_pos = p_rand.translation + phand_rand.translation
	ph.translation = rand_hand_pos
#	ph.translation = Std.get_global(hand_pos3d)
#	ph.rotation = hand_pos3d.rotation
	
	
	var mat = get_player_material(pid)
	if mat:
		ph.get_node("handMesh").set_surface_material(0, mat)
	
	ph.owner_id = pid
	if List.players.has(pid) and List.players[pid].has("name"):
		ph.owner_name = List.players[pid]["name"]
	
	
	cards.add_child(ph)
	
	List.paths[ph.name] = ph.get_path()
	




func process_received_world_state(world_state) -> void:
	state_manager.process_received_world_state(world_state)

func process_received_do(do) -> void:
	state_manager.process_received_do(do)






	"""
	here
	"""


