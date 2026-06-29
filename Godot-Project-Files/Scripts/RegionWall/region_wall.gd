extends Area2D
class_name RegionWall

@onready var item_display: Control = $ItemDisplay

@export var target_region: Vector2i = Vector2i(1, 0)
@export var required_items: Dictionary[ItemData, int] = {}
@export var gate_level: int = 1

var is_unlocked := false
var main: Main

func _ready() -> void:
	while !GameManager.is_game_loaded:
		await get_tree().process_frame
	
	main = GameManager.main
	for item: ItemData in required_items:
		var h_box: HBoxContainer = item_display.h_box_container
		var needed_item_display: NeededItemDisplay = NeededItemDisplay.new()
		needed_item_display.set_item(item)
		needed_item_display.set_item_count(required_items[item])
		
		h_box.add_child(needed_item_display)

#func _process(delta: float) -> void:
	
	#if Input.is_action_just_pressed("unlock_region"):
		
