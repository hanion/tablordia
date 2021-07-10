extends card
class_name snr_card

export(NodePath) onready var mesh = get_node(mesh) as MeshInstance

export(SpatialMaterial) var back_mat
export(SpatialMaterial) var rose_mat
export(SpatialMaterial) var skull_mat


func update_material() -> void:
	mesh = mesh as MeshInstance
	
	if is_hidden:
		mesh.set_material_override(back_mat)
	else:
		match card_value:
			0:
				mesh.set_material_override(rose_mat)
			1:
				mesh.set_material_override(skull_mat)




func set_is_hidden(_val) -> void:
	is_hidden = _val
	update_material()

