extends VBoxContainer

export(NodePath) onready var vbcolor = get_node(vbcolor) as VBoxContainer
export(NodePath) onready var colorpicker = get_node(colorpicker) as ColorPickerButton
export(NodePath) onready var vbjh = get_node(vbjh) as HBoxContainer
export(NodePath) onready var jbut = get_node(jbut) as Button
export(NodePath) onready var hbut = get_node(hbut) as Button
onready var tw = $Tween
onready var menu = get_node("../../..")

var is_name_valid : bool = false
var is_color_selected : bool = false

#if there is no saved data: make them disappear
func _ready() -> void: _on_linename_text_changed($linename.text)


func _on_linename_text_changed(new_text: String) -> void:
	is_name_valid = not (new_text.length() < 3)
	
	tweenit(vbcolor, is_name_valid)
	
	tweenit(vbjh,is_name_valid and is_color_selected)
	
	colorpicker.disabled = not is_name_valid
	jbut.disabled = not is_name_valid and is_color_selected
	hbut.disabled = not is_name_valid and is_color_selected
	
	menu.Name = new_text
	NetworkInterface.Name = new_text


func _on_ColorPickerButton_color_changed(_color: Color) -> void:
	is_color_selected = true
	tw.stop_all()
	tweenit(vbjh,1)
	_on_linename_text_changed($linename.text)
	menu.color =  _color
	NetworkInterface.color = _color



func tweenit(var obj, var to) -> void:
	tw.interpolate_property(obj,"modulate:a",obj.modulate.a,int(to),1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	tw.start()


