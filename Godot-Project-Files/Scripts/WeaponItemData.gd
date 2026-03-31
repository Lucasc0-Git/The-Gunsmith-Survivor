extends ItemData
class_name WeaponItemData

@export var weapon_data: WeaponData

func is_rotatable() -> bool:
	return weapon_data.rotatable
