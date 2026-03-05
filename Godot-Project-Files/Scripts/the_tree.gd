extends CharacterBody2D

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var ysort_node := get_parent()
@onready var main: Main = get_parent().get_parent()

var health: int = 50
var wood_item : ItemData

func _ready() -> void:
	wood_item = ItemRegistry.items["wood"]

func drop_items(amount: int) -> void:
	for i in range(amount):
		main.drop_item(wood_item, global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10)))

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		destroy()

func destroy() -> void:
	drop_items(1)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	collision.set_deferred("disabled", false)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	collision.set_deferred("disabled", true)
