extends Control

const SAVE_DIR = "user://saves/"

var save_path = SAVE_DIR + "save.dat"

onready var vb1info = get_node("../hbmenu/vb/vb1info")
onready var name_box = vb1info.get_node("linename")
onready var color_picker = vb1info.get_node("vbcolor/ColorPickerButton")


func save_player_data() -> void:
	var data := {
		"name":get_parent().Name,
		"color":get_parent().color
		}
	
	
	var dir = Directory.new()
	if not dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)
	
	
	var file = File.new()
	var er = file.open(save_path, File.WRITE)
	if er == OK:
		file.store_var(data)
		file.close()
		print("Player Data saved.")
	else:
		print("!! Error while saving player data. ",er)
	

func load_player_data() -> void:
	var file = File.new()
	if file.file_exists(save_path):
		
		var er = file.open(save_path, File.READ)
		if er == OK:
			var player_data = file.get_var()
			write_loaded_data(player_data)
			
			file.close()
			print("Succesfully loaded player data")
			
		else:
			print("!! Error while loading player data. ",er)


func write_loaded_data(player_data) -> void:
	var nam = player_data["name"]
	name_box.text = nam
	vb1info._on_linename_text_changed(nam)
	
	var color = player_data["color"]
	color_picker.set_pick_color(color)
	vb1info._on_ColorPickerButton_color_changed(color)
	





