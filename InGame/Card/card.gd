extends Spatial

class_name card
var card_id : int = -1

var card_value := 0
var card_value_second := 0

var is_hidden := true setget set_is_hidden

var is_in_hand := false
var in_hand

var is_in_slot := false
var in_slot

enum CARD_TYPE {
	item, resource,
	exp_island_item, exp_island_resource, exp_skill, exp_military,
	sh, uno, isk, snr
}

var type = CARD_TYPE.item

var is_in_container := false
var in_container# : container

var is_expansion_skill := false
var is_expansion_military := false


var is_resource := false
var is_item := false


var off_y = 0.04
onready var col = $CollisionShape



func set_is_hidden(val) -> void:
	if is_hidden == val: return
	is_hidden = val
	
	if global_translation.y < 0 and not is_in_hand: return
	
	for i in range(1,11):
		var num : float = float(i)/10.0
		scale.x = 1-num
		yield(get_tree().create_timer(0.001),"timeout")
	
	for i in range(1,11):
		var num : float = float(i)/10.0
		scale.x = num
		yield(get_tree().create_timer(0.001),"timeout")
	scale = Vector3(1,1,1)



func set_type(tip:String) -> void:
	match tip:
		"resource":
			type = CARD_TYPE.resource
			is_resource = true
		"item":
			type = CARD_TYPE.item
			
			is_item = true
		"exp_island_item":
			type = CARD_TYPE.exp_island_item
			is_item = true
		"exp_island_resource":
			type = CARD_TYPE.exp_island_resource
			is_resource = true
		"exp_skill":
			type = CARD_TYPE.exp_skill
			is_expansion_skill = true
		"exp_military":
			type = CARD_TYPE.exp_military
			is_expansion_military = true
		
		
		"Uno Card":
			type = CARD_TYPE.uno
		
		"52 Card":
			type = CARD_TYPE.isk
		
		"SNR Card":
			type = CARD_TYPE.snr
		
		"SH Card":
			type = CARD_TYPE.sh



func get_type() -> String:
	match type:
		CARD_TYPE.item:
			return "item"
		
		CARD_TYPE.resource:
			return "resource"
		
		CARD_TYPE.exp_island_item:
			return "exp_island_item"
		
		CARD_TYPE.exp_island_resource:
			return "exp_island_resource"
		
		CARD_TYPE.exp_military:
			return "exp_military"
		
		CARD_TYPE.exp_skill:
			return "exp_skill"
		
		CARD_TYPE.uno:
			return "Uno Card"
		CARD_TYPE.isk:
			return "52 Card"
		CARD_TYPE.snr:
			return "SNR Card"
		CARD_TYPE.sh:
			return "SH Card"
		
		_:
			return ""


func set_material(mat:SpatialMaterial) -> void:
	$mesh.set_material_override(mat)



func get_hand_name() -> String:
	if not is_in_hand: return ""
	if not in_hand or not is_instance_valid(in_hand): return ""
	return in_hand.name
func get_hand_index() -> int:
	if not is_in_hand: return -1
	if not in_hand or not is_instance_valid(in_hand): return -1
	return in_hand.get_card_index(self)


func get_container_name() -> String:
	if not is_in_container: return ""
	if not in_container or not is_instance_valid(in_container): return ""
	return in_container.name
func get_container_index() -> int:
	if not is_in_container: return -1
	if not in_container or not is_instance_valid(in_container): return -1
	return in_container.get_card_index(self)



