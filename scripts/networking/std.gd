extends Node

export(float,0.05,1.0) var tween_duration = 0.1

func complex_rotate(var cord: Vector3, var angle) -> Vector3:
	# ( cos(angle)+sin(angle)i )  (x+zi)
	# ( xcos(angle)-zsin(angle) ) + (zcos(angle)+xsin(angle))
	var new_coord = cord
	new_coord.x = (cord.x * cos(angle) - cord.z * sin(angle))
	new_coord.z = (cord.z * cos(angle) + cord.x * sin(angle))
	return new_coord

func complex_rotate_reverse(var cord: Vector3, var angle) -> Vector3:
	return complex_rotate(cord,2*PI-angle)


func get_object(var object_name) -> Node:
	var object_path = List.paths.get(object_name)
	
	var object = get_node(object_path)
	
	return object


func get_global(var obj) -> Vector3:
	var trans = obj.translation
	var parent = obj.get_parent()
	var parent_rotation_y = parent.rotation.y
	
	var obj_real_local_trans = complex_rotate_reverse(trans,parent_rotation_y)
	
	var parent_trans = parent.translation
	var obj_global: Vector3 = obj_real_local_trans + parent_trans
	
	return obj_global

func get_local(var obj, var global_trans := Vector3(0,0,0)) -> Vector3:
	
	var parent = obj.get_parent()
	var parent_trans = parent.translation
	var parent_rotation_y = parent.rotation.y
	
	var obj_real_global = complex_rotate(global_trans - parent_trans,parent_rotation_y)
	
	
	var obj_local: Vector3 = obj_real_global
	
	return obj_local


func erase_t(dict: Dictionary) -> void:
	erase_if_has(dict,"T")

func erase_if_has(dict: Dictionary, key) -> void:
	assert(not dict.empty(),"adasd")
	
	if dict.empty():
		push_error("Std:dictionary cant be empty")
		return
	
	if dict.has(key):
		var ER = dict.erase(key)
		
		if not ER:
			print("Std: !!! Error while erasing key:",key, " , in:",dict," , ER:",ER)
			push_error("Std: !!! Error while erasing t")



func erase_if_empty(dict: Dictionary, key) -> void:
	if dict.empty():
		push_error("Std:dictionary cant be empty")
		assert(
			not dict.empty(),
			"no"
		)
		return
	if not dict.has(key):
		push_error("Std:dictionary must have key")
		assert(
			dict.has(key),
			"sasdasdno"
		)
		return
	
	if dict[key].empty():
		var ER = dict.erase(key)
		
		if not ER:
			print("Std: !!! Error while erasing key:",key, " , in:",dict," , ER:",ER)
			push_error("Std: !!! Error while erasing empty")



func has_all(dict: Dictionary, key, key1 = null, key2 = null) -> bool:
	
	if not dict.has(key):
		return false
	
	if not key1: return true
	
	if not dict[key].has(key1):
		return false
	
	if not key2: return true
	
	if not dict[key][key1].has(key2):
		return false
	
	return true







