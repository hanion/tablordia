extends Spatial

export(Array,NodePath) var positions := []
const hand_path = "res://InGame/Hand/hand.tscn"

var currently_moving := []

onready var state_manager = $state_manager
onready var player = $player
onready var others = $others
onready var cards = $cards

var is_auto_save_on : bool = true

var br

func _ready():
	get_tree().set_auto_accept_quit(false)
	
	NetworkInterface.Main = self
	Spawner.cards_folder = cards
	SettingsUI.initialize()
	RCM.player = player
	HUD.player = player
	HUD.spawn_panel = $CanvasLayer/SpawnPanel
	UMB.fade()
	STATE_SAVER.cards = cards
	
	print("	-Game is ready-\n")
	
	if not get_tree().is_network_server():
		CMD.mj([])
		yield(get_tree().create_timer(0.1),"timeout")


func _spawn_player(var pid):
	if pid == get_tree().get_network_unique_id(): return
	if others.has_node(str(pid)): return
	
	
	var plo = preload("res://Systems/Small/otherPlayer.tscn").instance()
	plo.set_name(str(pid))
	plo.set_network_master(pid)
	
	
	
	var material = get_player_material(pid)
	plo.get_child(0).set_surface_material(0, material)
	
	if List.players[pid]["name"] == "server":
		plo.get_child(0).visible = false
	
	others.add_child(plo)
	
	List.players[pid]["pointer"] = plo


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

func process_received_do_collection(do_collection) -> void:
	state_manager.process_received_do_collection(do_collection)



func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		if is_auto_save_on:
			STATE_SAVER.get_current_state_and_save()
		
		get_tree().quit()
