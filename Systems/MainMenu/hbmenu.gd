extends HBoxContainer

export(NodePath) onready var vb0pq = get_node(vb0pq) as VBoxContainer
export(NodePath) onready var vb1info = get_node(vb1info) as VBoxContainer
export(NodePath) onready var vb2host = get_node(vb2host) as VBoxContainer
export(NodePath) onready var vb3join = get_node(vb3join) as VBoxContainer
export(NodePath) onready var join_ip = get_node(join_ip) as LineEdit
export(NodePath) onready var join_port = get_node(join_port) as LineEdit
export(NodePath) onready var host_port = get_node(host_port) as LineEdit
onready var menu = get_parent()

func _ready() -> void:
	hide_all()
	vb0pq.visible = true

func hide_all() -> void:
	vb0pq.visible = false
	vb1info.visible = false
	vb2host.visible = false
	vb3join.visible = false



func _on_play_pressed() -> void:
	vb0pq.visible = false
	vb1info.visible = true


func _on_settings_pressed() -> void:
	SettingsUI.open_ui()


func _on_quit_pressed() -> void:
	get_tree().quit()



func _on_first_join_pressed() -> void:
	vb1info.visible = false
	vb3join.visible = true
func _on_vbjc_cancel_pressed() -> void:
	vb3join.visible = false
	vb1info.visible = true

func _on_first_host_pressed() -> void:
	vb1info.visible = false
	vb2host.visible = true
func _on_vbch_cancel_pressed() -> void:
	vb2host.visible = false
	vb1info.visible = true




func _on_host_pressed() -> void:
	hide_all()
	menu.Host(int(host_port.text))

func _on_join_pressed() -> void:
	hide_all()
	menu.Join(join_ip.text,int(join_port.text))



func _on_autojoin_pressed() -> void:
	menu.deploy_server_listener()

