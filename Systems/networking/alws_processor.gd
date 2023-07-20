extends Node


"""
var all_latest_world_states = { # alws
	obj_name:{
		T:time,
		pos:pos,
		rot:rot,
		DO:{"DO STATE"}
		}
	}
"""

func process_alws(alws:Dictionary) -> void:
	yield(get_tree().create_timer(0.3),"timeout")
#	print("\n\n\n\n              ---- RECEİVED ALWS ----- \n",alws.keys())
	print("\n\n\n\n              ---- RECEİVED ALWS ----- \n")
	for i in alws:
		print(i, " : ", alws[i])
	print("\n\n\n")
	
	for key in alws.keys():
		var obj = Std.get_object(key)
		
		if not obj: 
			print(".couldn't find ",key)
			return
		
		
		
		if obj is card:
			if obj.is_in_deck or obj.is_in_hand:
				continue
		
		if alws[key].has("O"):
			obj.transform.origin = alws[key]["O"]
		if alws[key].has("R"):
			obj.rotation = alws[key]["R"]
		
		print(".object synced (",obj.name,")")


