extends HSplitContainer
# hs


onready var inspector = $configurer/Inspector


func selected(info) -> void:
	inspector.set_inspector(info)
