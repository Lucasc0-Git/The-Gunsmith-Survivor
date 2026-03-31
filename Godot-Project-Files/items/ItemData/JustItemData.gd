extends ItemData
class_name JustItemData

##Data for only just items in the game.
@export var just_data: JustData

func is_rotatable() -> bool:
	return just_data.rotatable
