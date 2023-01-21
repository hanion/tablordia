extends Node

const SAVE_DIR = "user://saves/"

var save_path = SAVE_DIR + "settings.dat"

var settings := {
	"rendering/quality/filters/msaa" : 0,
	"environment/ssao_enabled" : false,
	"environment/ssao_quality" : 0,
	"environment/ssao_blur" : 0,
	"environment/dof_blur_near_enabled" : true,
	"environment/ss_reflections_enabled" : false,
	"environment/glow_enabled" : false,
	
	
	"shading" : true,
	"shade_table" : true,
	"black_sky":true
	}



func save_settings() -> void:
	var data := settings
	
	
	var dir = Directory.new()
	if not dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)
	
	
	var file = File.new()
	var er = file.open(save_path, File.WRITE)
	if er == OK:
		file.store_var(data)
		file.close()
		
#		print("Settings saved.")
#		UMB.log(1,"Settings","Settings saved.")
	else:
		print("sdata:	!! Error while saving player data. ",er)
		UMB.log(2,"Settings","Error while saving settings : "+str(er))

func load_settings() -> void:
	var file = File.new()
	if file.file_exists(save_path):
		
		var er = file.open(save_path, File.READ)
		if er == OK:
			var _settings = file.get_var()
			write_loaded_data(_settings)
			
			file.close()
			print("sdata:	Loaded settings")
#			 NO need for this in release
#			UMB.log(1,"Settings","Succesfully loaded settings") 
		else:
			print("sdata:	!! Error while loading settings. ",er)
			UMB.log(2,"Settings","Error while loading settings : "+str(er))


func write_loaded_data(data : Dictionary) -> void:
	
	for k in data.keys():
		if settings.has(k):
			settings[k] = data[k]
			get_parent().seset(k,data[k])
			get_parent().load_set_to_ui(k,data[k])
	



# Write Set Setting
func write_seset(ss_path : String, val) -> void:
	
	if not settings.has(ss_path):
		UMB.log(2,"Settings","settings does not have '" + ss_path + "'.")
		return
	
	if ProjectSettings.has_setting(ss_path):
		ProjectSettings.set_setting(ss_path, val)
	settings[ss_path] = val
	
#	Removed for more clean look
#	UMB.log(1, "Settings", ss_path + " : " + str(val))
	save_settings()

















