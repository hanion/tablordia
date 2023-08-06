extends card
class_name br_card


export(Array,SpatialMaterial) var res_mats := []
export(Array,SpatialMaterial) var item_mats := []

var is_expansion_skill := false


const items := [
	[
	Vector3(0.95,0,0.874), # 0 back
	Vector3(0.05,0,0.124), # 1 punch
	Vector3(0.25,0,0.124), # 2 kick
	Vector3(0.35,0,0.124), # 3 blow dart
	Vector3(0.55,0,0.124), # 4 spiked club
	Vector3(0.65,0,0.124), # 5 fire
	Vector3(0.85,0,0.124), # 6 torch
	Vector3(0.95,0,0.124), # 7 revolution
	
	Vector3(0.15,0,0.375), # 8 trap
	Vector3(0.35,0,0.375), # 9 sprint
	Vector3(0.45,0,0.375), # 10 knockdown
	Vector3(0.55,0,0.375), # 11 food pile
	Vector3(0.65,0,0.375), # 12 wood pile
	Vector3(0.75,0,0.375), # 13 iron pile
	Vector3(0.85,0,0.375), # 14 stone pile
	Vector3(0.95,0,0.375), # 15 gold pile
	
	Vector3(0.05,0,0.623), # 16 bandage
	Vector3(0.25,0,0.623), # 17 medkit
	Vector3(0.55,0,0.623), # 18 run away
	Vector3(0.75,0,0.623), # 19 grenade
	Vector3(0.95,0,0.623), # 20 bullet
	
	Vector3(-0.05,0,-0.124) # 21 back
	],[
	Vector3(0.785,0,0.083), # 0 airdrop
	Vector3(0.071,0,0.25), # 1 backpack
	Vector3(0.357,0,0.25), # 2 chest
	Vector3(0.5,  0,0.25), # 3 pocket knife
	Vector3(0.642,0,0.25), # 4 fishing rod
	Vector3(0.785,0,0.25), # 5 pot
	Vector3(0.928,0,0.25), # 6 sewing kit
	
	Vector3(0.071,0,0.416), # 7 pickaxe
	Vector3(0.214,0,0.416), # 8 shovel
	Vector3(0.357,0,0.416), # 9 bow & arrow
	Vector3(0.5,  0,0.416), # 10 axe
	Vector3(0.642,0,0.416), # 11 slingshot
	Vector3(0.785,0,0.416), # 12 hammer
	Vector3(0.927,0,0.416), # 13 spear
	
	Vector3(0.071,0,0.583), # 14 harpoon
	Vector3(0.214,0,0.583), # 15 knife
	Vector3(0.357,0,0.583), # 16 cowbar
	Vector3(0.5  ,0,0.583), # 17 revolver
	Vector3(0.642,0,0.583), # 18 shotgun
	Vector3(0.785,0,0.583), # 19 old pistol
	Vector3(0.928,0,0.583), # 20 sawed off shotgun
	
	Vector3(0.071,0,0.75), # 21 short rifle
	Vector3(0.214,0,0.75), # 22 bola
	Vector3(0.355,0,0.75), # 23 boomerang
	#escape
	Vector3(0.5  ,0,0.75), # 24 bottle
	Vector3(0.642,0,0.75), # 25 sextant
	Vector3(0.785,0,0.75), # 26 raft
	Vector3(0.928,0,0.75), # 27 radio
	
	Vector3(0.071,0,0.917), # 28 compass
	Vector3(0.214,0,0.917), # 29 sailboat
	Vector3(0.357,0,0.917), # 30 sailing 101
	Vector3(0.5  ,0,0.917), # 31 snorkel
	Vector3(0.642,0,0.917), # 32 spyglass
	Vector3(0.785,0,0.917), # 33 buoy
	Vector3(0.928,0,0.917)  # 34 back
	]
	]

func update_material():
	var mat: SpatialMaterial 
	if is_resource:
		mat = res_mats[card_value].duplicate(true)
	elif is_item:
		var base = 1 if card_value > 29 else 0
		mat = item_mats[base].duplicate(true)
		mat.set_uv1_offset(items[base][card_value-(30*base)])
	elif is_expansion_skill:
		mat = $expansion_skills.get_mat(card_value, card_value_second)
	
	set_material(mat)




func set_is_hidden(val) -> void:
	.set_is_hidden(val)
	if is_item:
		var mat
		if val:
			mat = item_mats[0].duplicate(true)
			mat.set_uv1_offset(items[0][0])
			set_material(mat)
		else:
			var base = 1 if card_value > 29 else 0
			mat = item_mats[base].duplicate(true)
			mat.set_uv1_offset(items[base][card_value-(30*base)])
			set_material(mat)
		return
	
	elif is_resource:
		var mat
		if val:
			mat = res_mats[0].duplicate(true)
		else:
			mat = res_mats[card_value].duplicate(true)
		set_material(mat)
	
	elif is_expansion_skill:
		var new_card_val = 0 if val else card_value
		var mat = $expansion_skills.get_mat(new_card_val, card_value_second)
		set_material(mat)
		
		
	



func notify_dispenser() -> void:
	update_material()
	is_hidden = false
	is_in_dispenser = false
	
	if not in_dispenser: return
	if not is_instance_valid(in_dispenser): return
	in_dispenser.notify()

