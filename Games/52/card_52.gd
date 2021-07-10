extends card
class_name card_52

export(NodePath) onready var mesh = get_node(mesh) as MeshInstance

export(SpatialMaterial) var mat

export(Array,Texture) var clubs
export(Array,Texture) var diamonds
export(Array,Texture) var hearts
export(Array,Texture) var spades

func _ready():
	mat = mat.duplicate(true) as SpatialMaterial


func update_material() -> void:
	mat = mat as SpatialMaterial
	var texture 
	
	if is_hidden:
		texture = clubs[0]
	else:
		match card_value_second:
			0:
				texture = clubs[card_value]
			1:
				texture = diamonds[card_value]
			2:
				texture = hearts[card_value]
			3:
				texture = spades[card_value]
		
	
	mat.set_texture(SpatialMaterial.TEXTURE_ALBEDO,texture)
	mesh.set_material_override(mat)





func set_is_hidden(_val) -> void:
	is_hidden = _val
	update_material()



