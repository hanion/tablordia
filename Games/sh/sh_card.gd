extends card
class_name sh_card


export(NodePath) onready var mesh = get_node(mesh) as MeshInstance

export(SpatialMaterial) var lib
export(SpatialMaterial) var fas
export(SpatialMaterial) var hit
export(SpatialMaterial) var l_article
export(SpatialMaterial) var f_article
export(SpatialMaterial) var ja
export(SpatialMaterial) var nein
export(SpatialMaterial) var l_pm
export(SpatialMaterial) var f_pm
export(SpatialMaterial) var back


func update_material() -> void:
	mesh = mesh as MeshInstance
	
	var mat: SpatialMaterial = back
	
	if is_hidden:
		mat = back
	else:
		match card_value:
			0:
				mat = lib
			1:
				mat = fas
			2:
				mat = hit
			3:
				mat = l_article
			4:
				mat = f_article
			5:
				mat = ja
			6:
				mat = nein
			7:
				mat = l_pm
			8:
				mat = f_pm
	
	mesh.set_material_override(mat)




func set_is_hidden(_val) -> void:
	is_hidden = _val
	update_material()


