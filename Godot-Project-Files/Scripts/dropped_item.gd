extends Node2D
class_name DroppedItem

@onready var texture: Sprite2D = $Sprite2D

var item_data : ItemData

signal picked_up(item_data: ItemData)

func _ready() -> void:
	texture.texture = item_data.icon

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("player entered picking area")
	if body is Player:
		emit_signal("picked_up", item_data)
		queue_free()
