extends Sprite3D

func _ready():
	if name == "nametag3d_back":
		texture = get_node("../nametag3d/Viewport").get_texture()
	else:
		texture = $Viewport.get_texture()
