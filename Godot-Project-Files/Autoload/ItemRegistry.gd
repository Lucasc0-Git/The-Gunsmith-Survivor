@tool
extends Node

## Call it like ItemRegistry.items["id_of_the_item"]
var items: Dictionary[String, ItemData] = {}
var loaded: bool = false

signal items_loaded

func _ready() -> void:
	print("✅ ItemRegistry _ready() called")
	print("   Tree position: ", get_path())
	print("   Current scene exists? ", get_tree().current_scene != null)
	
	
	print("Loading items...")
	load_items()
	items_loaded.emit()
	loaded = true
	print("Items loaded")
	notify_property_list_changed()



func load_items() -> void:
	items.clear()
	
	var files := ResourceLoader.list_directory("res://items/Inv_items")
	
	for file in files:
		if not file.ends_with(".tres"):
			continue
		
		var path := "res://items/Inv_items/" + file
		var item := load(path) as ItemData
		if item:
			items[item.id] = item
			print("Loading item ", item.id, " as: ", item)
		else:
			printerr("Failed to cast to ItemData: ", path)

func get_all_ids() -> PackedStringArray:
	return PackedStringArray(items.keys())
