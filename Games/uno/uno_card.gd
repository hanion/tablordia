extends card
class_name uno_card

export(NodePath) onready var value_mesh = get_node(value_mesh) as MeshInstance
export(NodePath) onready var plate_mesh = get_node(plate_mesh) as MeshInstance

export(SpatialMaterial) var values_mat
export(SpatialMaterial) var plates_mat


const posses := [
	Vector3(0.261,0,0.266), #0
	Vector3(0.33 ,0,0.266), #1
	Vector3(0.397,0,0.266), #2
	Vector3(0.465,0,0.266), #3
	Vector3(0.535,0,0.266), #4
	Vector3(0.603,0,0.266), #5
	Vector3(0.671,0,0.266), #6
	Vector3(0.739,0,0.266), #7
	Vector3(0.808,0,0.266), #8
	Vector3(0.876,0,0.266), #9
	Vector3(0.056,0,0.266), #10 block
	Vector3(0.124,0,0.266), #11 reverse
	Vector3(0.193,0,0.266), #12 +2
	Vector3(0.057,0,0.695), #13 +4
	Vector3(0.945,0,0.266), #14 color_change
	Vector3(0.196,0,0.695), #15 uno (back)
	
	Vector3(0    ,0,0.695)  #16 empty
	]

export var colors := [
	Color.red,
	Color.yellow,
	Color.blue,
	Color.green,
	Color.black
]

func _ready():
	values_mat = values_mat.duplicate(true) as SpatialMaterial
	plates_mat = plates_mat.duplicate(true) as SpatialMaterial
	

func update_material() -> void:
	var vmat = values_mat
	var cmat = plates_mat
	
	if is_hidden:
		vmat.set_uv1_offset(posses[15])
		cmat.set_albedo(colors[4])
	else:
		vmat.set_uv1_offset(posses[card_value])
		cmat.set_albedo(colors[card_value_second])
	
	
	value_mesh.set_material_override(vmat)
	plate_mesh.set_material_override(cmat)




func set_is_hidden(_val) -> void:
	is_hidden = _val
	update_material()



