extends card
class_name resource

export(Array,SpatialMaterial) var materyals := []

var resource_value
var is_hidden := true setget set_is_hidden


func change_resource(index: int) -> void:
	$mesh.set_material_override(materyals[index])


func notify_dispenser() -> void:
#	if not is_hidden:
	is_hidden = false
	is_in_dispenser = false
	in_dispenser.notify()
	change_resource(resource_value)



func set_is_hidden(val) -> void:
	is_hidden = val
	if val:
		change_resource(0)
	else:
		change_resource(resource_value)
