extends CanvasLayer

func _ready():
	if not OS.has_touchscreen_ui_hint():
		$Control.visible = false
		$Control2.visible = false
