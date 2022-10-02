extends Node
# CMD
const valid_commands : Array = [
	"quit","say","table","kick","w","c","set_class","table_inf","help__"
	]

func parse_command(var txt: String) -> void:
	if not txt.begins_with('/'): return
	if txt.length() < 2: return
	txt.erase(0,1)
	var args = txt.split(" ",false)
	
	call_command(args)




func call_command(args:PoolStringArray) -> void:
	if args == null: return
	if args.size() < 1: return
	
	var command = args[0]
	
	var extra_args : PoolStringArray = args
	extra_args.remove(0)
	
	if valid_commands.has(command):
		call_deferred(command,extra_args)
	else:
		UMB.log(2,"cmd","Couldn't find the command '"+command+"'.")


func quit(_ea:PoolStringArray) -> void:
	get_tree().call_deferred("quit")


func say(ea:PoolStringArray) -> void:
	
	var txt : String = ""
	for t in ea:
		txt += t + " "
	if get_tree().has_network_peer():
		UMB.logs(0,NetworkInterface.Name, txt)
	else:
		UMB.log(0,NetworkInterface.Name, txt)
		UMB.log_er("Console","No network peer to send message")



func table(ea:PoolStringArray) -> void:
	if not ea: return
	var num : int = int(ea[0])
	SettingsUI.local_chance_table_mat(num)

func table_inf(ea:PoolStringArray) -> void:
	if not ea: return
	var num : int = int(ea[0])
	print("a ",num)
	SettingsUI.change_table_mesh(num)
	


func w(ea:PoolStringArray) -> void:
	for pid in List.players:
		if List.players[pid]["name"] == ea[0]:
			ea.remove(0)
			var txt = ea.join(" ")
			UMB.logw(pid,NetworkInterface.Name,txt)
			return



func c(ea:PoolStringArray) -> void:
	if not List.players[NetworkInterface.uid].has("class"):
		UMB.log(1,"cmd","you have no class")
		return
	
	
	var my_clas = List.players[NetworkInterface.uid]["class"]
	
	if my_clas == "liberal": 
		UMB.log(1,"cmd","[color=#32a3f9]liberal[/color]s can not see each other")
		return
	
	if my_clas == "none": 
		UMB.log(1,"cmd","you have no class")
		return
	
	
	if ea.size() > 0: 
		c_chat(ea)
		return
	
	
	for pid in List.players:
		if not List.players[pid].has("class"): continue
		if not List.players[pid]["class"] == my_clas: continue
	
		var col = List.players[pid]["color"] as Color
		var color = col.to_html()
		
		var pname = List.players[pid]["name"]
		
		var bb_name:String = "[color=#" + color + "]" + pname + "[/color]"
		var bb_class:String = "[color=#" + Color.red.to_html() + "]" + my_clas + "[/color]"
		
		var txt = bb_name + " is also " + bb_class
		UMB.log(1,"cmd",txt)

func c_chat(ea:PoolStringArray) -> void:
	var my_clas = List.players[NetworkInterface.uid]["class"]
	
	var ids : Array = []
	
	for pid in List.players:
		if not List.players[pid].has("class"): continue
		if not List.players[pid]["class"] == my_clas: continue
		
		ids.append(pid)
	
	
	var txt = ea.join(" ")
	UMB.logc(ids,NetworkInterface.Name,txt)
	



func help__(_ea:PoolStringArray) -> void:
	var text = ""
	for com in valid_commands:
		text += com + ", "
	
	UMB.log(1,"cmd","commands: "+text)







func set_class(ea:PoolStringArray) -> void:
	if ea.size() < 1: return
	List.remote_set_class(NetworkInterface.uid,ea[0])



