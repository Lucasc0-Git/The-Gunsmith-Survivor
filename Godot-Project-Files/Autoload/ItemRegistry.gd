@tool
extends Node

## Call it like ItemRegistry.items["id_of_the_item"]
var items: Dictionary = {}

func _init() -> void:
	load_items()

func load_items() -> void:
	items.clear()
	
	#var item_files := [
		#"Glock_item.tres",
		#"Shotgun_item.tres",
		#"Apple_item.tres",
		#"Wood_item.tres",
		#"Torch_item.tres",
		#"BasicStation_item.tres"
	#]
	
	var dir := DirAccess.open("res://items/Inv_items")
	if !dir: printerr("Item data corrupted!")
	for file in dir.get_files():
		if file.ends_with(".tres"):
			var item := load("res://items/Inv_items/" + file) as ItemData
			items[item.id] = item
	#
	#for file_name : String in item_files:
		#var item_res := load("res://items/Inv_items/" + file_name) as ItemData
		#items[item_res.id] = item_res
