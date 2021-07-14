extends Spatial

var my_paths := {}


func _ready() -> void:
	get_paths()
	write_paths()
	var player = get_node("../player")
	player.connect("started_dragging",self,"on_started_dragging")
	player.connect("stopped_dragging",self,"on_stopped_dragging")
	
	
	if not get_tree().is_network_server(): return


func get_paths() -> void:
	var w = $w.get_children()
	var b = $b.get_children()
	
	var my_path = "/root/Main/" + self.name # /root/Main/chess0
	
	my_paths[self.name] = my_path
	
	var base_w = my_path + "/w/"
	var base_b = my_path + "/b/"
	
	
	for piece in w:
		var final_path: String = base_w + piece.name
		my_paths[piece.name] = final_path
	for piece in b:
		var final_path: String = base_b + piece.name
		my_paths[piece.name] = final_path


func write_paths() -> void:
	for objname in my_paths.keys():
		if List.paths.has(objname):
			push_error("List already has this objects path")
		List.paths[objname] = my_paths[objname]




func on_started_dragging(drg) -> void:
	if not drg == self: return
	
	for c in $w.get_children():
		c.set_collision_layer_bit(0,false)
		c.sleeping = true
	for c in $b.get_children():
		c.set_collision_layer_bit(0,false)
		c.sleeping = true

func on_stopped_dragging() -> void:
	for c in $w.get_children():
		c.set_collision_layer_bit(0,true)
		c.sleeping = false
	for c in $b.get_children():
		c.set_collision_layer_bit(0,true)
		c.sleeping = false


func _on_started_dragging_via_network() -> void:
	on_started_dragging(self)
	
	check_if_still_moving()

func check_if_still_moving():
	var old_pos = translation
	yield(get_tree().create_timer(0.1),"timeout")
	var new_pos = translation
	
	if old_pos == new_pos:
		print("stopped")
		on_stopped_dragging()
	else:
		check_if_still_moving()





