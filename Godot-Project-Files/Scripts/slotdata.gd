extends Node
class_name SlotData

var item_data: ItemData = null
var amount: int = 0

func is_empty() -> bool:
	return item_data == null or amount <= 0

func clear() -> void:
	item_data = null
	amount = 0
