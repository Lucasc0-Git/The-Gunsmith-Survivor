extends ItemData
class_name CloseWeaponItemData

@export var close_weapon_data: CloseWeaponData

func is_rotatable() -> bool:
	return close_weapon_data.rotatable
