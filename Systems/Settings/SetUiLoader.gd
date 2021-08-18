extends Control

export(NodePath) onready var c_shading = get_node(c_shading) as CheckBox
export(NodePath) onready var c_shade_table = get_node(c_shade_table) as CheckBox
export(NodePath) onready var o_msaa = get_node(o_msaa) as OptionButton
export(NodePath) onready var o_ao = get_node(o_ao) as OptionButton
export(NodePath) onready var c_dof = get_node(c_dof) as CheckBox
export(NodePath) onready var c_ssr = get_node(c_ssr) as CheckBox
export(NodePath) onready var c_glow = get_node(c_glow) as CheckBox



func load_settings_to_ui(pth:String, val) -> void:
	
	match pth:
		"rendering/quality/filters/msaa":
			sif(o_msaa,val)
#		"environment/ssao_enabled":
#			environment.ssao_enabled = val
		"environment/ssao_quality":
			sif(o_ao,val)
#		"environment/ssao_blur":
#			environment.ssao_blur = val
		"environment/dof_blur_near_enabled":
			cif(c_dof,val)
		"environment/ss_reflections_enabled":
			cif(c_ssr,val)
		"environment/glow_enabled":
			cif(c_glow,val)
		
		"shading":
			cif(c_shading,val)
		"shade_table":
			cif(c_shade_table,val)

# Load CheckBox value to ui
func cif(ob:CheckBox, val:bool) -> void:
	if not ob.pressed == val:
		ob.pressed = val

# Load OptionButton value to ui
func sif(ob:OptionButton, val:int) -> void:
	if not ob.selected == val:
		ob.select(val)

