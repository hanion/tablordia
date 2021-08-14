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
	yield(get_tree().create_timer(2),"timeout")
#	print("\n\n\n\n                      ---- RECEİVED ALWS ----- \n.",alws)
	
	for key in alws.keys():
		var obj = Std.get_object(key)
		
		if obj:
			if alws[key].has("O"):
				obj.transform.origin = alws[key]["O"]
			if alws[key].has("R"):
				obj.rotation = alws[key]["R"]
			
			print(".object(",obj.name,") synced")
			
		else:
			key = key as String
			if key.begins_with("hand"):
				var hid = int(key.right(4))
				print("spawning hand for hid: ",hid)
				
#				get_parent().get_parent().Main._spawn_hand(hid)
			elif key.begins_with("card"):
				pass
			print(".couldn't find ",key)
			
