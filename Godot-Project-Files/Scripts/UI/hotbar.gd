extends Control
class_name Hotbar

## The onready var declaration
@onready var grid_container: GridContainer = $PanelContainer/GridContainer

## The export var declaration
@export var slot_count := 5
@export var slot_scene : PackedScene
@export var hud : Hud

## The basic var declaration
var slots: Array[Slot] = []
var selected_slot_index := 0

## The signals declaration
signal slot_selected(index: int)
signal slot_item_changed(index: int, slot_data: SlotData)

func _ready() -> void:
	for i in range(slot_count): ##Add slots to hotbar
		var index := i
		var slot := slot_scene.instantiate()
		## Connect signals
		slot.item_changed.connect(
			func(slot_data: SlotData, idx := index) -> void:
				_on_slot_item_changed(idx, slot_data)
		)
		slot.slot_left_clicked.connect(_on_slot_left_clicked)
		slot.slot_right_clicked.connect(_on_slot_right_clicked)
		## Add slot to hotbar
		grid_container.add_child(slot)
		## Set the right-bottom number in hotbar slot
		slot.set_hotbar_number(index + 1)
		## Add the slot to [slots] array
		slots.append(slot)
	select_slot(0)

func sync_from_player() -> void:
	if hud and hud.player:
		for i in range(slots.size()):
			slots[i].set_slot_data(hud.player.hotbar_slots[i])

func _on_slot_right_clicked(slot: Slot) -> void:
	var slot_data: SlotData = slot.slot_data.copy()
	if slot_data == null:
		slot_data = SlotData.new()
	if slot_data.is_empty(): return
	var og_amount: int = slot_data.amount
	if og_amount <= 1: return
	@warning_ignore("integer_division")
	var half_amount: int = og_amount / 2
	for invslot in grid_container.get_children():
		if invslot.slot_data.is_empty():
			if invslot == slot: return
			invslot.set_slot_data(slot_data)
			invslot.set_amount(slot_data.amount - half_amount)
			slot.set_amount(half_amount)
			return

func _on_slot_left_clicked(slot: Slot) -> void:
	if slot.slot_data == null or slot.slot_data.is_empty():
		return
	## Shift + leftclick → try to move the item to inventory
	if Input.is_key_pressed(KEY_SHIFT):
		try_move_item_to_inventory(slot)
		return

func find_hotbar_item(item: ItemData) -> int:
	var usable_amount: int = 0
	for slot: Slot in grid_container.get_children():
		if slot.slot_data == null: 
			var blank_data: SlotData = SlotData.new()
			slot.slot_data = blank_data
		if slot.slot_data.is_empty(): continue
		if slot.slot_data.item_data == item:
			usable_amount += slot.slot_data.amount
	return usable_amount

func remove_hotbar_item(item: ItemData, amount: int) -> void:
	if amount <= 0: return
	var amount_to_rm: int = amount
	for i in range(slots.size() -1, -1, -1):
		var slot: Slot = slots[i]
		if slot.slot_data == null or slot.slot_data.is_empty(): continue
		if slot.slot_data.item_data != item: continue
		var removing_amount: int = min(slot.slot_data.amount, amount_to_rm)
		slot.remove_amount(removing_amount)
		amount_to_rm -= removing_amount
		if amount_to_rm <= 0: return

func give_hotbar_item(item: ItemData, amount: int) -> int:
	var amount_to_add: int = amount
	
	# First pass — fill existing partial stacks
	for slot: Slot in grid_container.get_children():
		if slot.slot_data == null or slot.slot_data.is_empty(): continue
		if slot.slot_data.item_data != item: continue
		var space_left: int = slot.slot_data.item_data.max_stack - slot.slot_data.amount
		var adding_amount: int = min(space_left, amount_to_add)
		slot.add_amount(adding_amount)
		amount_to_add -= adding_amount
		if amount_to_add <= 0: return 0
	
	# Second pass — fill empty slots with remainder
	for slot: Slot in grid_container.get_children():
		if slot.slot_data == null or !slot.slot_data.is_empty(): continue
		var adding_amount: int = min(item.max_stack, amount_to_add)
		slot.set_item(item, adding_amount)
		amount_to_add -= adding_amount
		if amount_to_add <= 0: return 0
	
	return amount_to_add

func try_move_item_to_inventory(slot: Slot) -> void:
	if not hud or not hud.inventory or not hud.inventory.visible:
		return
	var slot_data: SlotData = slot.slot_data.copy()
	if slot_data == null or slot_data.is_empty(): return
	var amount_to_mv := slot_data.amount
	
	for inv_slot: Slot in hud.inventory.grid_container.get_children():
		if slot_data.equals(inv_slot.slot_data):
			if inv_slot.slot_data.is_full(): continue
			var space_left: int = inv_slot.slot_data.item_data.max_stack - inv_slot.slot_data.amount
			var moving_amount: int = min(space_left, amount_to_mv)
			slot.remove_amount(moving_amount)
			inv_slot.add_amount(moving_amount)
			var index := slots.find(slot)
			slot_item_changed.emit(index, slot.slot_data)
			amount_to_mv -= moving_amount
			if amount_to_mv <= 0: return
	
	## Find the first free slot in inventory
	for inv_slot in hud.inventory.grid_container.get_children():
		if inv_slot.slot_data.is_empty():
			slot.clear()
			inv_slot.set_slot_data(slot_data)
			var index := slots.find(slot) 
			var blank_data: SlotData = SlotData.new()
			slot_item_changed.emit(index, blank_data)
			return

func clear_selected_slot() -> void:
	var slot := slots[selected_slot_index]
	slot.clear()
	var blank_data: SlotData = SlotData.new()
	slot_item_changed.emit(selected_slot_index, blank_data)

## Select one slot in hotbar, highlight the selected slot
func select_slot(index: int) -> void:
	if index < 0 or index >= slots.size():
		return
	## Remove previous highlight
	if selected_slot_index >= 0 and selected_slot_index < slots.size():
		## Declare the previous highlight
		var prev := slots[selected_slot_index].get_node_or_null("Highlight")
		## Turn the highlight invisible
		if prev:
			prev.visible = false
	## Select the slot to be selected
	selected_slot_index = index
	## Declare the highlight for current slot
	var cur := slots[selected_slot_index].get_node_or_null("Highlight")
	## Turn the highlight visible
	if cur:
		cur.visible = true
	emit_signal("slot_selected", index)

func _on_item_amount_changed(new_amount: int) -> void:
	var slot := slots[selected_slot_index]
	slot.amount = new_amount

func set_item(index: int, slot_data: SlotData) -> void:
	slots[index].set_slot_data(slot_data)

func _on_slot_item_changed(index: int, slot_data: SlotData) -> void:
	slot_item_changed.emit(index, slot_data)
	if hud and hud.player:
		hud.player.set_hotbar_item(index, slot_data)
