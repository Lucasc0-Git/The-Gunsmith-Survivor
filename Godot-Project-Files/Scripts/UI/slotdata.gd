extends Resource
class_name SlotData

var item_data: ItemData = null
var amount: int = 0

func is_empty() -> bool:
	return item_data == null or amount <= 0

func is_full() -> bool:
	if item_data == null: return false
	return amount >= item_data.max_stack

func clear() -> void:
	item_data = null
	amount = 0

func copy() -> SlotData:
	var new_data: SlotData = SlotData.new()
	new_data.item_data = item_data
	new_data.amount = amount
	pass # On more vars in SlotData, add it here.
	return new_data

func equals(other: SlotData) -> bool:
	if other == null: return false
	return item_data == other.item_data and amount == other.amount

func is_same_item(other: SlotData) -> bool:
	if other == null or item_data == null or other.item_data == null: return false
	return item_data == other.item_data

func save_data() -> Dictionary:
	if is_empty():
		return {"empty": true}
	
	return {
		"empty": false,
		"item_id": item_data.id if item_data else "",
		"amount": amount
	}

func load_data(data: Dictionary) -> void:
	if !ItemRegistry: return
	if data.get("empty", false):
		clear()
		return
	
	var id: String = data.get("item_id", "")
	item_data = ItemRegistry.items.get(id)
	amount = int(data.get("amount", 0))
