extends ItemData
class_name BuildItemData

##Data for only build items in the game.
@export var build_data: BuildData

func is_rotatable() -> bool:
	return build_data.rotatable
