extends Button
class_name ItemCraftingButton

@export var item_data: ItemData

signal crafting_button_pressed(item_data: ItemData)

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	crafting_button_pressed.emit(item_data)
