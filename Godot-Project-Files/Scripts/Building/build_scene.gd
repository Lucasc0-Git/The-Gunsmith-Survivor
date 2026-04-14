@tool
extends StaticBody2D
class_name BuildScene

@export var collision_shape: CollisionShape2D
@export var sprite: Sprite2D

var _item_id: String = ""

func _ready() -> void:
	if Engine.is_editor_hint():
		if ItemRegistry.items.is_empty():
			await ItemRegistry.items_loaded
		notify_property_list_changed()

func _get_property_list() -> Array[Dictionary]:
	var ids := PackedStringArray()
	
	var dir := DirAccess.open("res://items/Inv_items")
	if dir:
		for file in dir.get_files():
			var item := load("res://items/Inv_items/" + file) as ItemData
			if item != null:
				ids.append(item.id)
	
	if ids.is_empty():
		ids = PackedStringArray(["(no items loaded)"])
	return [
		{
		"name": "item_id",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(ids)
		}
	]

func _get(property: StringName) -> Variant:
	if property == "item_id":
		return _item_id
	return null

func _set(property: StringName, value: Variant) -> bool:
	if property == "item_id":
		_item_id = value
		return true
	return false

func get_item_data() -> ItemData:
	if _item_id == "" or not Engine.has_singleton("ItemRegistry"):
		return null
	return ItemRegistry.items.get(_item_id, null)
