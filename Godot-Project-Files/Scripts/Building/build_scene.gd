@tool
extends StaticBody2D
class_name BuildScene

@export var collision_shape: CollisionShape2D
@export var sprite: Sprite2D
@export var mouse_input: Area2D

var _item_id: String = ""
var main: Main

func _ready() -> void:
	if Engine.is_editor_hint():
		if ItemRegistry.items.is_empty():
			await ItemRegistry.items_loaded
		notify_property_list_changed()
	mouse_input.input_event.connect(_on_input_event)
	if GameManager.main != null:
		main = GameManager.main
	else:
		printerr("The 'main' variable in build_scene.gd is null!")

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

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if main:
				main.show_build_item_tooltip(get_global_mouse_position())
