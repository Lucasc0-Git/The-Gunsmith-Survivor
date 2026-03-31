extends Resource
class_name SlotData

var item_data: ItemData = null
var amount: int = 0

func is_empty() -> bool:
	return item_data == null or amount <= 0

func clear() -> void:
	item_data = null
	amount = 0

func copy() -> SlotData:
	var new_data: SlotData = SlotData.new()
	new_data.item_data = item_data
	new_data.amount = amount
	pass # On more vars in SlotData, add it here.
	return new_data
