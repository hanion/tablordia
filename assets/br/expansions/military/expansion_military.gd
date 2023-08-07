extends Node

export(SpatialMaterial) var exp_military0
export(SpatialMaterial) var exp_military1



const coords0 := [
	Vector3(0.05, 0 , 0.071), # 1 /80 case fire
	Vector3(0.25, 0 , 0.071), # 3 /80 ammo crate
	Vector3(0.65, 0 , 0.071), # 7 /80 bullet
	Vector3(0.65, 0 , 0.214), # 17/80 tracer bullet
	Vector3(0.15, 0 , 0.357), # 22/80 improved bullet
	Vector3(0.65, 0 , 0.357), # 27/80 rocket
	Vector3(0.15, 0 , 0.5  ), # 32/80 stun grenade
	Vector3(0.35, 0 , 0.5  ), # 34/80 smoke grenade
	Vector3(0.55, 0 , 0.5  ), # 36/80 cluster grenade
	Vector3(0.75, 0 , 0.5  ), # 42/80 c4 explosive
	Vector3(0.95, 0 , 0.5  ), # 44/80 defuse kit
	Vector3(0.35, 0 , 0.643), # 48/80 air strike
	Vector3(0.45, 0 , 0.643), # 49/80 drone
	Vector3(0.55, 0 , 0.643), # 50/80 tactical medkit
	Vector3(0.95, 0 , 0.643), # 54/80 adrenaline syringe
	Vector3(0.15, 0 , 0.786), # 56/80 flare gun
	Vector3(0.35, 0 , 0.786), # 58/80 mortar
	Vector3(0.45, 0 , 0.786), # 59/80 rocket launcher
	Vector3(0.55, 0 , 0.786), # 60/80 military helmet
	Vector3(0.65, 0 , 0.786), # 61/80 military vest
	Vector3(0.75, 0 , 0.786), # 62/80 military backpack
	Vector3(0.85, 0 , 0.786), # 63/80 ghillie suit
	Vector3(0.95, 0 , 0.786), # 64/80 hand gun
	Vector3(0.05, 0 , 0.929), # 65/80 submachine gun
	Vector3(0.15, 0 , 0.929), # 66/80 submachine gun
	Vector3(0.25, 0 , 0.929), # 67/80 tactical shotgun
	Vector3(0.35, 0 , 0.929), # 68/80 pump action shotgun
	Vector3(0.45, 0 , 0.929), # 69/80 automatic rifle
	Vector3(0.55, 0 , 0.929), # 70/80 automatic rifle
	Vector3(0.65, 0 , 0.929), # 71/80 sniper rifle
	Vector3(0.75, 0 , 0.929), # 72/80 silencer
	Vector3(0.85, 0 , 0.929)  # 73/80 laser pointer
	# /\ is index 31
]

const coords1 := [
	# \/ is index 32
	Vector3(0.25, 1.743, 0.126), # 74/80 hardened grip
	Vector3(0.75, 1.743, 0.126), # 75/80 grnade launcher
	Vector3(0.25, 1.743, 0.374), # 76/80 thermal scope
	Vector3(0.75, 1.743, 0.374), # 77/80  scope
	Vector3(0.25, 1.743, 0.625), # 78/80  canteen
	Vector3(0.75, 1.743, 0.625), # 79/80  satcom
	Vector3(0.25, 1.743, 0.875)  # 80/80  rhib
	
]


func get_mat(value : int, _second_value : int) -> SpatialMaterial:
	var mat : SpatialMaterial
	
	if value < 32:
		mat = exp_military0.duplicate(true) as SpatialMaterial
		mat.set_uv1_offset(coords0[value])
	else:
		mat = exp_military1.duplicate(true) as SpatialMaterial
		mat.set_uv1_offset(coords1[value - 32])
	
	return mat
