extends ItemData
class_name HealItemData

##Data for only heal items in the game.
@export var heal_data: HealData

func is_rotatable() -> bool:
	return heal_data.rotatable
