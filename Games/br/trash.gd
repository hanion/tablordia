extends Area
class_name trash

export var only_items := false
export var only_resources := false
export var is_mesh_visible := false

var off_y = 0.02

var env := []

onready var old_pos = $old_card_pos
onready var col = $CollisionShape
onready var mes = $MeshInstance
onready var tween = $Tween


func _ready():
	col.shape = col.shape.duplicate(true)
	var player = get_node("../../player")
	player.connect("started_dragging",self,"on_started_dragging")
	player.connect("stopped_dragging",self,"on_stopped_dragging")



func add_to_trash(what: card) -> void:
	if not env.empty():
		if env.back() == what: return
	
	if only_items:
		if not what.is_item: return
	elif only_resources:
		if not what.is_resource: return
	
	
	what.is_in_trash = true
	what.in_trash = self
	
	env.append(what)
	what.global_translation = global_translation + Vector3(0, off_y ,0)
	
	# to fix rotation  (and slot is always 000)
	what.rotation = Vector3(0,0,0)
	
	hide_old_card()
	check_after_onesec()


func remove_from_trash(what: card) -> void:
	if env.empty(): return
	if not env.back() == what: return
	
	
	what.is_in_trash = false
	what.in_trash = null
	
	env.erase(what)
	
	bring_back_old_card()



func hide_old_card() -> void:
	if env.size() < 2: return
	var old_card = env[env.size()-2] as Spatial
	$Tween.stop_all()
	old_card.translation = old_pos.translation + translation



func bring_back_old_card() -> void:
	if env.size() < 1: return
	
	var old_card = env.back() as Spatial
#	old_card.translation = translation + Vector3(0, off_y ,0)
	
	tween.stop_all()
	var old_scale = old_card.scale
	tween.interpolate_property(
		old_card,
		"scale",
		Vector3(0,0,0),
		old_scale,
		Std.tween_duration*2,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
		)
	tween.interpolate_property(
		old_card,
		"translation",
		old_card.translation,
		translation + Vector3(0, off_y ,0),
		Std.tween_duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
		)
	tween.start()









var _is_player_dragging := false

func on_started_dragging(it) -> void:
	if not it is br_card: return
	if only_items and it.is_item:
		col.shape.extents.y = 0.16
		mes.visible = is_mesh_visible
	elif only_resources and it.is_resource:
		col.shape.extents.y = 0.16
		mes.visible = is_mesh_visible
	
	if env.empty(): return
	if env.back():
		env.back().set_collision_layer_bit(0,false)
	
	_is_player_dragging = true

func on_stopped_dragging() -> void:
	col.shape.extents.y = 0.04
	mes.visible = false
	
	if env.empty(): return
	if env.back():
		env.back().set_collision_layer_bit(0,true)
	
	_is_player_dragging = false











func check_after_onesec():
	yield(get_tree().create_timer(0.1),"timeout")
	if not env: return
	if not env.back().is_in_trash: return
	if not env.back().in_trash == self: return
	if env.back().global_translation == global_translation + Vector3(0, off_y ,0): return
	
	if _is_player_dragging:
		return
	
	env.back().global_translation = global_translation + Vector3(0, off_y ,0)
#	env.is_in_slot = true
#	env.in_slot = self
	
	print("checked trash")
	check_after_onesec()





