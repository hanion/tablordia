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




func on_stopped_dragging() -> void:
	col.disabled = true
	mes.visible = false


func check_after_onesec():
	yield(get_tree().create_timer(1),"timeout")
	if not env: return
	if not env.is_in_slot: return
	if not env.in_slot == self: return
	if env.translation == translation + Vector3(0, off_y ,0): return
	
	env.translation = translation + Vector3(0, off_y ,0)
#	env.is_in_slot = true
#	env.in_slot = self
	print("checked")
	check_after_onesec()





