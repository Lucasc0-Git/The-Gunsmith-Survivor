extends ItemData
class_name InteractableItemData

##Data for only interactable items in the game.
@export var interactable_data: InteractableData

func is_rotatable() -> bool:
	return interactable_data.rotatable if interactable_data else false
