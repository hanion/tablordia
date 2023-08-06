extends Node

export(SpatialMaterial) var exp_skill_pack
export(SpatialMaterial) var exp_skills


export(Array, StreamTexture) var exp_skills_images



const coords := [
	Vector3(0.25, 0 ,-0.1), # back
	Vector3(0.25, 0 , 0.1), # skills list
	Vector3(0.75, 0 , 0.1), # 1
	Vector3(0.25, 0 , 0.3), # 2
	Vector3(0.75, 0 , 0.3), # 3
	Vector3(0.25, 0 , 0.5), # 4
	Vector3(0.75, 0 , 0.5), # 5
	Vector3(0.25, 0 , 0.7), # 6
	Vector3(0.75, 0 , 0.7), # 7
]


func get_mat(value : int, second_value : int) -> SpatialMaterial:
	if value == -1:
		var mat = exp_skill_pack.duplicate(true) as SpatialMaterial
		return mat
	
	var mat = exp_skills.duplicate(true) as SpatialMaterial
	
	
	mat.albedo_texture = exp_skills_images[second_value]
	mat.set_uv1_offset(coords[value])
	return mat
