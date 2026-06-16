extends Node2D
class_name DroppedItem

@onready var texture: Sprite2D = $Sprite2D

var item_data : ItemData

signal picked_up(item_data: ItemData)

func _ready() -> void:
	if not texture:
		var sprite := Sprite2D.new()
		add_child(sprite)
		texture = sprite
	texture.texture = item_data.icon

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		emit_signal("picked_up", item_data)
		queue_free()

func save_data() -> Dictionary:
	return {
		"pos": global_position,
		"item_id": item_data.id
	}

func load_data(data: Dictionary) -> void:
	global_position = data.get("pos", Vector2.ZERO)
	if ItemRegistry.items:
		item_data = ItemRegistry.items.get(data.get("item_id", ""))
	else:
		print("waiting for ItemRegistry")
		await  ItemRegistry.items_loaded
		item_data = ItemRegistry.items.get(data.get("item_id", ""))
