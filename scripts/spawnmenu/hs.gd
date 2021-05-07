extends HSplitContainer
# hs


onready var inspector = $configurer/Inspector


func selected(game, type, naem, val) -> void:
	inspector.set_inspector(game, type, naem, val)
