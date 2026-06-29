extends Control
class_name NeededItemDisplay

@onready var icon: TextureRect = $TextureRect
@onready var count_label: Label = $Label
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	count_label.hide()
	color_rect.hide()

func set_item(item_data: ItemData) -> void:
	if item_data:
		icon.texture = item_data.icon

func set_item_count(amount: int) -> void:
	count_label.text = str(amount)
	count_label.show()

func show_count() -> void:
	count_label.show()
func hide_count() -> void:
	count_label.hide()

func be_red() -> void:
	color_rect.show()

func be_normal() -> void:
	color_rect.hide()
