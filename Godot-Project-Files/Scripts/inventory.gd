extends Control
class_name Inventory

## The onready var declaration
@onready var grid_container: GridContainer = $PanelContainer/VBoxContainer/MarginContainer/GridContainer

## The export var declaration
@export var slot_scene : PackedScene

## The basic var declaration
var tooltip: Tooltip

var glock_item : ItemData
var shotgun_item : ItemData
var apple_item : ItemData
var wood_item : ItemData

var inv_slot : Slot
var player: Player
var hud : Hud

func _ready() -> void:
	## Assign proper data to proper items
	glock_item = ItemRegistry.items["glock"]
	shotgun_item = ItemRegistry.items["shotgun"]
	apple_item = ItemRegistry.items["apple"]
	wood_item = ItemRegistry.items["wood"]
	
	visible = false
	
	## Give the inventory some slots
	for i in range(20): #The range is how much slots will the inventory have
		var slot := slot_scene.instantiate()
		slot.slot_left_clicked.connect(_on_slot_left_click)
		slot.slot_right_clicked.connect(_on_slot_right_click)
		var data: SlotData = SlotData.new()
		slot.set_slot_data(data)
		grid_container.add_child(slot) #add the slot as child to grid_container
	## Connect tooltip signals from all the slots
	for slot in grid_container.get_children():
		slot.connect("mouse_entered_slot", Callable(self, "_show_tooltip"))
		slot.connect("mouse_exited_slot", Callable(self, "_hide_tooltip"))
	# Give some slots some items for debugging, needs to be removed after debugging
	fill_slot(0, glock_item, 1)
	fill_slot(1, shotgun_item, 1)
	fill_slot(2, apple_item, 5)
	fill_slot(3, apple_item, 10)
	fill_slot(4, apple_item, 16)
	fill_slot(5, wood_item, 32)

func _on_slot_right_click(slot: Slot) -> void:
	pass

func _on_slot_left_click(slot: Slot) -> void:
	if slot.slot_data == null or slot.slot_data.is_empty():
		return
	## Shift + leftclick → try to move the item to hotbar
	if Input.is_key_pressed(KEY_SHIFT):
		move_item_to_hotbar(slot)
		return

func move_item_to_hotbar(slot: Slot) -> void:
	if !player: return
	
	var slot_data: SlotData = slot.slot_data.copy()
	if slot_data == null or slot_data.is_empty(): 
		print("cancelling move_item_to_hotbar()")
		return
	
	# Find first free slot in hotbar
	for i in range(player.hotbar_slots.size()):
		if player.hotbar_slots[i].is_empty():
			slot.clear()
			_hide_tooltip()
			player.set_hotbar_item(i, slot_data)
			hud.hotbar.set_item(i, slot_data)
			return

func fill_slot(slot: int, item: ItemData, amount: int) -> void:
	if amount > item.max_stack:
		push_error("Func fill_slot() has the wrong amount!")
		return
	inv_slot = grid_container.get_child(slot)
	var data: SlotData = SlotData.new()
	data.item_data = item
	data.amount = amount
	inv_slot.set_slot_data(data)

func _show_tooltip(slot_data: SlotData) -> void:
	tooltip.show_tooltip(slot_data)

func _hide_tooltip() -> void:
	tooltip.hide_tooltip()
