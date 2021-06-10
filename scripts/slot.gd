extends Area
class_name slot

export var only_items := false
export var only_resources := false
export var is_mesh_visible := false

var off_y = 0.02

var env

onready var col = $CollisionShape
onready var mes = $MeshInstance
onready var tween = $Tween

var _is_player_dragging = false

func _ready():
	col.shape = col.shape.duplicate(true)
	var player = get_node("../../player")
	player.connect("started_dragging",self,"on_started_dragging")
	player.connect("stopped_dragging",self,"on_stopped_dragging")





func add_to_slot(obj: card) -> void:
#	if env:
#		if not env == obj: return
	
	if only_items:
		if not obj.is_item: return
	elif only_resources:
		if not obj.is_resource: return
	
	
	obj.is_in_slot = true
	obj.in_slot = self
	
	env = obj
	obj.translation = translation + Vector3(0, off_y ,0)
	check_after_onesec()


func remove_from_slot(obj) -> void:
	if not env: return
	
	obj.is_in_slot = false
	obj.in_slot = null
	
	env = null



func on_started_dragging(it) -> void:
	if not it is br_card: return
	if only_items and it.is_item:
		col.disabled = false
		mes.visible = is_mesh_visible
	
	
	elif only_resources and it.is_resource:
		
		col.disabled = false
		mes.visible = is_mesh_visible
	
	if it == env:
		env.is_in_slot = false
		env.in_slot = null
		env = null
	
	_is_player_dragging = true



func on_stopped_dragging() -> void:
	col.disabled = true
	mes.visible = false
	_is_player_dragging = false


func check_after_onesec():
	
	yield(get_tree().create_timer(0.1),"timeout")
	if not env: 
		print("slotcheck error: 1")
		return
	if not env.is_in_slot: 
		prints("slotcheck error: 2",env.name,"as",self.name,env.is_in_slot)
		env.is_in_slot = true
		check_after_onesec()
		return
	if not env.in_slot == self: 
		print("slotcheck error: 3")
		return
	if env.translation == translation + Vector3(0, off_y ,0): 
		return
	
	if _is_player_dragging:
		print("slotcheck error: 4")
		return
	
	
	env.translation = translation + Vector3(0, off_y ,0)
#	env.is_in_slot = true
#	env.in_slot = self
	print("slotcheck: checked ", env.name, " as ", self.name)
	check_after_onesec()





