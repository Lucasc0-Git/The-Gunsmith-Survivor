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
var torch_item: ItemData
var basic_crafting: BasicCraftingUI

var inv_slot : Slot
var player: Player
var hud : Hud

func _ready() -> void:
	## Assign proper data to proper items
	glock_item = ItemRegistry.items["glock"]
	shotgun_item = ItemRegistry.items["shotgun"]
	apple_item = ItemRegistry.items["apple"]
	wood_item = ItemRegistry.items["wood"]
	torch_item = ItemRegistry.items["torch"]
	visible = false
	## Give the inventory some slots
	for i in range(20): #The range is how much slots will the inventory have
		var slot := slot_scene.instantiate()
		slot.slot_left_clicked.connect(_on_slot_left_click)
		slot.slot_right_clicked.connect(_on_slot_right_click)
		slot.slot_mousewheeled.connect(_on_slot_mousewheeled)
		var data: SlotData = SlotData.new()
		slot.set_slot_data(data)
		grid_container.add_child(slot) #add the slot as child to grid_container
	## Connect tooltip signals from all the slots
	for slot in grid_container.get_children():
		slot.connect("mouse_entered_slot", Callable(self, "_show_tooltip"))
		slot.connect("mouse_exited_slot", Callable(self, "_hide_tooltip"))
	# Give some slots some items for debugging, needs to be removed after debugging
	fill_slot(1, shotgun_item, 1)
	fill_slot(4, apple_item, 16)
	fill_slot(5, wood_item, 32)
	fill_slot(2, torch_item, 16)

func _on_slot_right_click(slot: Slot) -> void:
	var slot_data: SlotData = slot.slot_data.copy()
	if slot_data == null:
		slot_data = SlotData.new()
	if slot_data.is_empty(): return
	var og_amount: int = slot_data.amount
	if og_amount <= 1: return
	var half_amount: int = int(og_amount / 2.0)
	for invslot in grid_container.get_children():
		if invslot.slot_data.is_empty():
			if invslot == slot: return
			invslot.set_slot_data(slot_data)
			invslot.set_amount(slot_data.amount - half_amount)
			slot.set_amount(half_amount)
			return

func _on_slot_mousewheeled(slot: Slot) -> void:
	if slot.slot_data == null: 
		slot.slot_data = SlotData.new()
	if slot.slot_data.is_empty(): return
	
	for invslot in grid_container.get_children():
		if invslot.slot_data == null:
			invslot.slot_data = SlotData.new()
		if invslot.slot_data.is_empty():
			invslot.set_item(slot.slot_data.item_data, 1)
			slot.remove_amount(1)
			return

func _on_slot_left_click(slot: Slot) -> void:
	if slot.slot_data == null or slot.slot_data.is_empty():
		return
	## Shift + leftclick → try to move the item to hotbar
	if Input.is_key_pressed(KEY_SHIFT):
		move_item_to_hotbar(slot)
		return

func can_craft(recipe: Dictionary[ItemData, int]) -> bool:
	for key in recipe:
		var has_item: bool = false
		var has_amount: bool = false
		var required_amount: int = recipe[key]
		
		var total_amount: int = 0
		for slot: Slot in grid_container.get_children():
			if slot.slot_data == null or slot.slot_data.is_empty(): continue
			if slot.slot_data.item_data == key:
				has_item = true
				total_amount += slot.slot_data.amount
		
		if total_amount >= required_amount:
			has_amount = true
		if !has_amount or !has_item: return false
	
	return true

func rm_items_by_recipe(recipe: Dictionary[ItemData, int]) -> void:
	for item: ItemData in recipe:
		remove_item(item, recipe[item])

func find_item(item: ItemData) -> int:
	var usable_amount: int = 0
	for slot: Slot in grid_container.get_children():
		if slot.slot_data == null: 
			var blank_data: SlotData = SlotData.new()
			slot.slot_data = blank_data
		if slot.slot_data.is_empty(): continue
		if slot.slot_data.item_data == item:
			usable_amount += slot.slot_data.amount
	return usable_amount

func do_have_item(item: ItemData, needed_amount: int = 1) -> bool:
	var total: int = 0
	for slot: Slot in grid_container.get_children():
		if slot.slot_data == null: 
			var blank_data: SlotData = SlotData.new()
			slot.slot_data = blank_data
		if slot.slot_data.is_empty(): continue
		if slot.slot_data.item_data == item:
			total += slot.slot_data.amount
	if total >= needed_amount:
		return true
	return false

func give_item(item: ItemData, amount: int = 1) -> void:
	var amount_to_add: int = amount
	
	# First pass — fill existing partial stacks
	for slot: Slot in grid_container.get_children():
		if slot.slot_data == null or slot.slot_data.is_empty(): continue
		if slot.slot_data.item_data != item: continue
		var space_left: int = slot.slot_data.item_data.max_stack - slot.slot_data.amount
		var adding_amount: int = min(space_left, amount_to_add)
		slot.add_amount(adding_amount)
		amount_to_add -= adding_amount
		if amount_to_add <= 0: return
	
	# Second pass — fill empty slots with remainder
	for slot: Slot in grid_container.get_children():
		if slot.slot_data == null or !slot.slot_data.is_empty(): continue
		var adding_amount: int = min(item.max_stack, amount_to_add)
		slot.set_item(item, adding_amount)
		amount_to_add -= adding_amount
		if amount_to_add <= 0: return

func remove_item(item: ItemData, amount: int = 1) -> void:
	var amount_to_rm: int = amount
	var slots := grid_container.get_children()
	for i in range(slots.size() -1, -1, -1):
		var slot: Slot = slots[i]
		if slot.slot_data == null or slot.slot_data.is_empty(): continue
		if slot.slot_data.item_data != item: continue
		
		var removing_amount: int = min(slot.slot_data.amount, amount_to_rm)
		slot.remove_amount(removing_amount)
		amount_to_rm -= removing_amount
		if amount_to_rm <= 0: return

func move_item_to_hotbar(slot: Slot) -> void:
	if !player: return
	
	var slot_data: SlotData = slot.slot_data.copy()
	if slot_data == null or slot_data.is_empty(): 
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
