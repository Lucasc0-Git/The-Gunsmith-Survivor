extends Node

## Call it like ItemRegistry.items["id_of_the_item"]
var items: Dictionary = {}

func _ready() -> void:
	var item_files := [
		"Glock_item.tres",
		"Shotgun_item.tres",
		"Apple_item.tres",
		"Wood_item.tres",
		"Torch_item.tres",
		"BasicStation_item.tres"
	]
	for file_name : String in item_files:
		var item_res := load("res://items/Inv_items/" + file_name) as ItemData
		items[item_res.id] = item_res
