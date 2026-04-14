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
	
	print("Loading items from: res://items/Inv_items")
	
	var dir := DirAccess.open("res://items/Inv_items")
	if !dir: printerr("DirAccess failed! Error: ", DirAccess.get_open_error())
	
	print("Dir opened, files: ", dir.get_files())
	
	for file in dir.get_files():
		
		print("Found file: ", file)
		
		if file.ends_with(".tres"):
			var path := "res://items/Inv_items/" + file
			var item := load("res://items/Inv_items/" + file) as ItemData
			if item == null:
				printerr("Failed to cast to ItemData: ", path)
			else:
				print("Loaded item: ", item.id)
				items[item.id] = item
	
	print("Total items loaded: ", items.size())

func get_all_ids() -> PackedStringArray:
	return PackedStringArray(items.keys())
