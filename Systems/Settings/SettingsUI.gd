extends Control

export(NodePath) onready var pu = get_node(pu) as WindowDialog
export(NodePath) onready var res = get_node(res) as OptionButton
export(NodePath) onready var gq = get_node(gq) as OptionButton

export(NodePath) onready var sul = get_node(sul) as VBoxContainer
export(NodePath) onready var msg_example = get_node(msg_example) as RichTextLabel


var env_parent
var environment
var table_mesh : MeshInstance
var inf_table_mesh : MeshInstance
var chat_dragger_v : VSplitContainer
var chat_dragger_h : HSplitContainer
var chat_alpha : float = 1.0
var auto_hide_chat : bool = true
var auto_hide_chat_time : int = 10

var table_mat_marble = preload("res://InGame/Table/Marble016_2K-PNG/marble.tres")
var table_mat_wood = preload("res://InGame/Table/Wood067_2K-PNG/wood.tres")
var table_mat_carpet = preload("res://InGame/Table/Carpet012_2K-PNG/carpet.tres")
var table_mat_rug1 = preload("res://InGame/Table/table_mat_rug1.tres")
var table_mat_rug2 = preload("res://InGame/Table/table_mat_rug2.tres")
var table_mat_rug3 = preload("res://InGame/Table/table_mat_rug3.tres")
var table_mat_rug4 = preload("res://InGame/Table/table_mat_rug4.tres")
var table_mat_rug5 = preload("res://InGame/Table/table_mat_rug5.tres")
var table_mat_base_color = preload("res://InGame/Table/base_color_mat.tres")

var sky_black = preload("res://sky_black.tres")
var sky_default = preload("res://sky_default.tres")

# The preset to use when starting the project
# 0: Low
# 1: Medium
# 2: High
# 3: Ultra
const default_preset = 1

# The available display resolutions
const display_resolutions = [
	Vector2(640, 360),
	Vector2(1024, 576),
	
	Vector2(1280, 720),
	Vector2(1366, 768),
	Vector2(1600, 900),
	Vector2(1920, 1080),
	Vector2(2560, 1440),
	Vector2(3200, 1800),
	Vector2(3840, 2160),
	]

const presets = [
	# Low
	{
		"environment/glow_enabled": [false, "Disabled"],
		"environment/ss_reflections_enabled": [false, "Disabled"],
		"environment/ssao_enabled": [false, "Disabled"],
		"environment/ssao_blur": [Environment.SSAO_BLUR_1x1, ""],
		"environment/ssao_quality": [Environment.SSAO_QUALITY_LOW, ""],
		"rendering/quality/filters/msaa": [Viewport.MSAA_DISABLED, "Disabled"]
	},

	# Medium
	{
		"environment/glow_enabled": [false, "Disabled"],
		"environment/ss_reflections_enabled": [false, "Disabled"],
		"environment/ssao_enabled": [false, "Disabled"],
		"environment/ssao_blur": [Environment.SSAO_BLUR_1x1, ""],
		"environment/ssao_quality": [Environment.SSAO_QUALITY_LOW, ""],
		"rendering/quality/filters/msaa": [Viewport.MSAA_2X, "2×"],
	},

	# High
	{
#		"environment/glow_enabled": [true, "Enabled"],
		"environment/ss_reflections_enabled": [false, "Disabled"],
		"environment/ssao_enabled": [true, "Medium-quality"],
		"environment/ssao_blur": [Environment.SSAO_BLUR_1x1, ""],
		"environment/ssao_quality": [Environment.SSAO_QUALITY_LOW, ""],
		"rendering/quality/filters/msaa": [Viewport.MSAA_4X, "4×"],
	},

	# Ultra
	{
#		"environment/glow_enabled": [true, "Enabled"],
#		"environment/ss_reflections_enabled": [false, "Disabled"],
		"environment/ss_reflections_enabled": [true, "Enabled"], # reflections broken with 2 lights
		"environment/ssao_enabled": [true, "High-quality"],
		"environment/ssao_blur": [Environment.SSAO_BLUR_2x2, ""],
		"environment/ssao_quality": [Environment.SSAO_QUALITY_MEDIUM, ""],
		"rendering/quality/filters/msaa": [Viewport.MSAA_8X, "8×"],
	},
	]



func _ready():
	visible = false
	pu.connect("popup_hide",self,"close_ui")
	rpc_config("change_table_mat",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rpc_config("change_table_color",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rpc_config("_change_table_mesh",MultiplayerAPI.RPC_MODE_REMOTESYNC)


func open_ui() -> void:
	pu.popup()
	visible = true
	Std.is_blocked_by_ui = true
	
	initialize()

func initialize() -> void:
	if not environment == null: return
	if not get_node("/root/").has_node("Main"): return
	
	env_parent = get_node("/root/Main/environment")
	environment = env_parent.get_node("WorldEnvironment").get_environment()
	
	chat_dragger_h = UMB.get_node("hs")
	chat_dragger_v = UMB.get_node("hs/vs")
	
	table_mesh = get_node("/root/Main/tablo/table/tableMesh")
	inf_table_mesh = get_node("/root/Main/tablo/table/tableMeshInf")
	
	
	
	# Initialize the project on the default preset
	gq.select(default_preset)
	_on_graphics_preset_change(default_preset)
	
	yield(get_tree().create_timer(0.1),"timeout")
	seset("shade_table",true)

	# Cache screen size into a variable
	var screen_size := OS.get_screen_size()

	# Add resolutions to the display resolution dropdown
	for resolution in display_resolutions:
		if resolution.x <= screen_size.x and resolution.y <= screen_size.y:
			res.add_item(str(resolution.x) + "×" + str(resolution.y))

	# Add a "Fullscreen" item at the end and select it by default
	res.add_item("Fullscreen")
	res.select(0)
	$SettingsSaver.load_settings()


func close_ui() -> void:
	visible = false
	pu.visible = false
	Std.is_blocked_by_ui = false

# Returns a string containing BBCode text of the preset description.
func construct_bbcode(preset: int) -> String:
	return "Changed to:" + \
	"""[table=2]
	[cell][b]    Lightining [/b][/cell] [cell]""" + str("Disabled" if preset == 0 else "Enabled") + """[/cell]
	[cell][b]    Anti-aliasing (MSAA)[/b][/cell] [cell]""" + str(presets[preset]["rendering/quality/filters/msaa"][1]) + """[/cell]
	[cell][b]    Ambient occlusion[/b][/cell] [cell]""" + str(presets[preset]["environment/ssao_enabled"][1]) + """[/cell]
	[cell][b]    Bloom[/b][/cell] [cell]""" + str(presets[preset]["environment/glow_enabled"][1]) + """[/cell]
	[cell][b]    Screen-space reflections [/b][/cell] [cell]""" + str(presets[preset]["environment/ss_reflections_enabled"][1]) + """[/cell]
	[/table]"""




func _on_graphics_preset_change(preset: int) -> void:
#	var txtbb = construct_bbcode(preset)
#	UMB.log(1,"Settings",txtbb)
	
	# Apply settings from the preset
	for setting in presets[preset]:
		var value = presets[preset][setting][0]
		seset(setting, value)
	
	seset("shading",(not preset == 0))
	
	seset("shade_table",(not preset == 0))
	
#	seset("black_sky",(not preset == 0))
	
	$SettingsSaver.load_settings()

func _on_resolution_changed(id):
	if id < res.get_item_count() - 1:
		OS.set_window_fullscreen(false)
		OS.set_window_size(display_resolutions[id])
#		get_tree().set_screen_stretch( SceneTree.STRETCH_MODE_2D,
# SceneTree.STRETCH_ASPECT_KEEP,display_resolutions[id])
		
		# May be maximized automatically if the previous window size was bigger than screen size
		OS.set_window_maximized(false)
	else:
		# The last item of the OptionButton is always "Fullscreen"
		OS.set_window_fullscreen(true)



###############################################################################
############################## ADVANCED SETTINGS ##############################
###############################################################################
# Set Setting
func seset(pth:String, val) -> void:
	match pth:
		"rendering/quality/filters/msaa":
			get_viewport().msaa = val
		"environment/ssao_enabled":
			environment.ssao_enabled = val
		"environment/ssao_quality":
			environment.ssao_quality = val
		"environment/ssao_blur":
			environment.ssao_blur = val
		"environment/dof_blur_near_enabled":
			environment.dof_blur_near_enabled = false # near blur kinda sucks
#			environment.dof_blur_near_enabled = val
		
		"environment/ss_reflections_enabled":
			environment.ss_reflections_enabled = val
		"environment/glow_enabled":
			environment.glow_enabled = val
		
		
		"shading":
			for child in env_parent.get_children():
				if child is DirectionalLight:
					child.shadow_enabled = val
#			env_parent.visible = val
		"shade_table":
			var mat = table_mesh.get_surface_material(0) as SpatialMaterial
			mat.flags_unshaded = not val
			table_mesh.set_surface_material(0,mat)
#		"black_sky":
#			environment.background_sky = sky_black if val else sky_default
		
	$SettingsSaver.write_seset(pth, val)

func load_set_to_ui(pth:String, val) -> void:
	sul.load_settings_to_ui(pth,val)


func _on_msaa_option_button_item_selected(index):
	seset("rendering/quality/filters/msaa",index)

func _on_ao_option_button_item_selected(index):
	var enabled = (not index == 0)
	seset("environment/ssao_enabled",enabled)
	
	seset("environment/ssao_quality", index)

func _on_ssao_blur_option_button_item_selected(index):
	seset("environment/ssao_blur", index)

func _on_dof_near_check_box_toggled(val):
	seset("environment/dof_blur_near_enabled",val)

func _on_shading_check_box_toggled(val):
	seset("shading",val)

func _on_shade_table_check_box_toggled(val):
	seset("shade_table",val)

func _on_ssr_check_box_toggled(val):
	seset("environment/ss_reflections_enabled",val)

func _on_glow_check_box_toggled(val):
	seset("environment/glow_enabled",val)


func _on_chat_check_box_toggled(val):
	UMB.visible = val


func _on_chat_alpha_h_slider_value_changed(value):
	UMB.modulate.a = value
	chat_alpha = value


func _on_chat_bg_alpha_h_slider_value_changed(value):
	msg_example.get_stylebox("normal").bg_color.a = value


func _on_chat_size_y_h_slider_value_changed(value):
	chat_dragger_v.split_offset = (1-value) * 371 - 200

func _on_chat_size_x_h_slider_value_changed(value): #-400 -150
	chat_dragger_h.split_offset = (1-value) * (-250) - 150



func _on_chat_fade_check_box_toggled(val):
	UMB.auto_hide_chat = val
	auto_hide_chat = val
	if val: 
		UMB.fade()
	else:
		UMB.reset_alpha()



func _on_chatautohide_time_spin_box_value_changed(value):
	auto_hide_chat_time = value
	UMB.auto_hide_chat_time = value


func _on_table_mat_option_button_item_selected(index):
	rpc("change_table_mat",index)


remote func change_table_mat(index) -> void:
	local_chance_table_mat(index)
func local_chance_table_mat(index) -> void:
	var mat
	match index:
		0:
			mat = table_mat_wood
		1:
			mat = table_mat_marble
		2:
			mat = table_mat_carpet
			
		3:
			mat = table_mat_rug1
		4:
			mat = table_mat_rug2
		5:
			mat = table_mat_rug3
		6:
			mat = table_mat_rug4
		7:
			mat = table_mat_rug5
		_:
			return
	
	local_change_table_mesh(int(index < 3))
	inf_table_mesh.set_surface_material(0,mat)
	table_mesh.set_surface_material(0,mat)

func change_table_mesh(num:int) -> void:
	rpc("_change_table_mesh",num)
remote func _change_table_mesh(num) -> void:
	local_chance_table_mat(num)
func local_change_table_mesh(num) -> void:
	if num == 1:
		inf_table_mesh.visible = true
		table_mesh.visible = false
	else:
		inf_table_mesh.visible = false
		table_mesh.visible = true




func _on_ColorPickerButton_color_changed(color: Color) -> void:
	rpc("change_table_color",color)
remote func change_table_color(col) -> void:
	local_change_table_mesh(1)
	var mat = table_mat_base_color
	mat.albedo_color = col
	table_mesh.set_surface_material(0,mat)
	inf_table_mesh.set_surface_material(0,mat)

