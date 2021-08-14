extends Control

export(NodePath) onready var pu = get_node(pu) as WindowDialog
export(NodePath) onready var res = get_node(res) as OptionButton
export(NodePath) onready var gq = get_node(gq) as OptionButton

var environment


# The preset to use when starting the project
# 0: Low
# 1: Medium
# 2: High
# 3: Ultra
const default_preset = 0

# The available display resolutions
const display_resolutions = [
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
		"rendering/quality/filters/msaa": [Viewport.MSAA_DISABLED, "Disabled"],
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
		"environment/glow_enabled": [true, "Enabled"],
		"environment/ss_reflections_enabled": [false, "Disabled"],
		"environment/ssao_enabled": [true, "Medium-quality"],
		"environment/ssao_blur": [Environment.SSAO_BLUR_1x1, ""],
		"environment/ssao_quality": [Environment.SSAO_QUALITY_LOW, ""],
		"rendering/quality/filters/msaa": [Viewport.MSAA_4X, "4×"],
	},

	# Ultra
	{
		"environment/glow_enabled": [true, "Enabled"],
		"environment/ss_reflections_enabled": [true, "Enabled"],
		"environment/ssao_enabled": [true, "High-quality"],
		"environment/ssao_blur": [Environment.SSAO_BLUR_2x2, ""],
		"environment/ssao_quality": [Environment.SSAO_QUALITY_MEDIUM, ""],
		"rendering/quality/filters/msaa": [Viewport.MSAA_8X, "8×"],
	},
	]





func _ready():
	visible = false
	pu.connect("popup_hide",self,"close_ui")
	


func open_ui() -> void:
	pu.popup()
	visible = true
	
	if not environment == null: return
	
	environment = get_node("/root/Main/environment/WorldEnvironment")
	environment = environment.get_environment()
	
	
	
	# Initialize the project on the default preset
	gq.select(default_preset)
	_on_graphics_preset_change(default_preset)

	# Cache screen size into a variable
	var screen_size := OS.get_screen_size()

	# Add resolutions to the display resolution dropdown
	for resolution in display_resolutions:
		if resolution.x < screen_size.x and resolution.y < screen_size.y:
			res.add_item(str(resolution.x) + "×" + str(resolution.y))

	# Add a "Fullscreen" item at the end and select it by default
	res.add_item("Fullscreen")
	res.select(0)


func close_ui() -> void:
	visible = false


# Returns a string containing BBCode text of the preset description.
func construct_bbcode(preset: int) -> String:
	return "Changed to: \n\n" + \
	"""[table=2]
	[cell][b]Anti-aliasing (MSAA)[/b][/cell] [cell]""" + str(presets[preset]["rendering/quality/filters/msaa"][1]) + """[/cell]
	[cell][b]Ambient occlusion[/b][/cell] [cell]""" + str(presets[preset]["environment/ssao_enabled"][1]) + """[/cell]
	[cell][b]Bloom[/b][/cell] [cell]""" + str(presets[preset]["environment/glow_enabled"][1]) + """[/cell]
	[cell][b]Screen-space reflections[/b][/cell] [cell]""" + str(presets[preset]["environment/ss_reflections_enabled"][1]) + """[/cell]
	[/table]""" + "\n"




func _on_graphics_preset_change(preset: int) -> void:
	var txtbb = construct_bbcode(preset)
	UMB.log(1,"Settings",txtbb)
	# Apply settings from the preset
	for setting in presets[preset]:
		var value = presets[preset][setting][0]
		ProjectSettings.set_setting(setting, value)

		match setting:
			# Environment settings
			"environment/glow_enabled":
				environment.glow_enabled = value
			"environment/ss_reflections_enabled":
				environment.ss_reflections_enabled = value
			"environment/ssao_enabled":
				environment.ssao_enabled = value
			"environment/ssao_blur":
				environment.ssao_blur = value
			"environment/ssao_quality":
				environment.ssao_quality = value

			# Project settings
			"rendering/quality/filters/msaa":
				get_viewport().msaa = value
	
#	UMB.log(1,"System","Succesfully changed settings.")

func _on_resolution_changed(id):
	if id < res.get_item_count() - 1:
		OS.set_window_fullscreen(false)
		OS.set_window_size(display_resolutions[id])
		# May be maximized automatically if the previous window size was bigger than screen size
		OS.set_window_maximized(false)
	else:
		# The last item of the OptionButton is always "Fullscreen"
		OS.set_window_fullscreen(true)

