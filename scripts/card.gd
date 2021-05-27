extends Spatial

class_name card


var card_value := 0

var is_hidden := true setget set_is_hidden

var is_in_deck := false
var in_deck

var is_in_hand := false
var in_hand

var is_in_dispenser := false
var in_dispenser

var is_in_trash := false
var in_trash

var is_in_slot := false
var in_slot



var is_resource := false
var is_item := false


var off_y = 0.04
onready var col = $CollisionShape



func set_is_hidden(val) -> void:
	is_hidden = val



func set_type(tip:String) -> void:
	is_resource = false
	is_item = false
	
	
	match tip:
		"resource":
			is_resource = true
		"item":
			is_item = true
		



func set_material(mat:SpatialMaterial) -> void:
	$mesh.set_material_override(mat)





