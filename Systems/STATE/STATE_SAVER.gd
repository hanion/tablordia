extends Node

var cards : Spatial

onready var save_in_file = $save_in_file


func SAVE_TO_FILE() -> void:
	UMB.log(1,"STATE","Saving World State to file...")
	save_in_file.save_world_state_to_file()

func LOAD_FROM_FILE() -> void:
	UMB.log(1,"STATE","Loading World State from file...")
	save_in_file.load_world_state_from_file()




func get_current_state_and_save() -> void:
	var all_objects : Array = []
	
	for obj in cards.get_children():
		all_objects.append(obj)
	
	
	# sort cards to last
	for obj in all_objects:
		if obj is card:
			all_objects.erase(obj)
			all_objects.append(obj)
	
	
	
	for obj in all_objects:
		if obj is card: continue
		
		elif obj is hand:
#			print("saving hand state of      ", obj.name)
			STATE.update_hand_state(obj)
			
			for child in obj.get_children():
				if child is card:
					STATE.update_card_state(child)
		
		elif obj is container:
#			print("saving container state of ", obj.name)
#			print("	container has data=",obj.data_inv.size(), " card=",obj.card_inv.size())
			STATE.update_container_state(obj)
		
		else:
#			print("saving game state of      ", obj.name)
			STATE.update_game_state(obj)
	
	
	# save state of cards
	for obj in all_objects:
		if obj is card:
#			print("saving card state of      ", obj.name)
			STATE.update_card_state(obj)
	
	
	SAVE_TO_FILE()
