@tool
extends Node

## Call it like ItemRegistry.items["id_of_the_item"]
var items: Dictionary = {}

signal items_loaded

func _ready() -> void:
	pass
	items_loaded.emit()
	notify_property_list_changed()

func _init() -> void:
	load_items()

func load_items() -> void:
	items.clear()
	
	var dir := DirAccess.open("res://items/Inv_items")
	if !dir: printerr("DirAccess failed! Error: ", DirAccess.get_open_error())
	
	for file in dir.get_files():
		if file.ends_with(".tres"):
			var path := "res://items/Inv_items/" + file
			var item := load("res://items/Inv_items/" + file) as ItemData
			if item == null:
				printerr("Failed to cast to ItemData: ", path)
			else:
				items[item.id] = item

func get_all_ids() -> PackedStringArray:
	return PackedStringArray(items.keys())
