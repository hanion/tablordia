extends Spatial

var off_y = 0.04
onready var col = $CollisionShape

var env := []
const resource_path = "res://scenes/resource.tscn"


func _ready():
	yield(get_tree().create_timer(0.2),"timeout")
	create_env()
	shuffle_env()
#	spawn_resource()

func create_env():
	for _a in range(30):
		env.append(1)
		env.append(2)
		env.append(3)
		env.append(4)
	for _i in range(20):
		env.append(5)


func spawn_resource() -> void:
	var rs = load(resource_path).instance()
	get_parent().add_child(rs)
	
	setup_resource(rs)
	
	rs.set_name("resource"+str(GLOBAL.resource_index))
	GLOBAL.resource_index += 1
	
	rs.in_dispenser = self
	rs.is_in_dispenser = true
	
	rs.translation = translation + Vector3(0,off_y,0)
	
	List.paths[rs.name] = rs.get_path()



func setup_resource(rs) -> void:
	var resource_value
	if GLOBAL.resource_index > env.size()-1:
		print("dispenser: !!! out of array")
		push_error("Dispenser is emptied")
		
		resource_value = env[GLOBAL.resource_index-env.size()]
	else:
		resource_value = env[GLOBAL.resource_index]
	
	
	rs.resource_value = resource_value





func shuffle_env() -> void:
	randomize()
	
	var siz = env.size()
	
	for i in range(siz):
		i = siz - i
		i -= 1
		
		if i == 0: continue
		
		var ran = randi() % i
		
		var first_val = env[i]
		var second_val = env[ran]
		
		env[i] = second_val
		env[ran] = first_val
	
#	print(env)



func notify() -> void:
	spawn_resource()


func set_received_inv(inv) -> void:
	env = inv
	spawn_resource()
