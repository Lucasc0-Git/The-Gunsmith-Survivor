extends Control
class_name Hotbar

## The onready var declaration
@onready var grid_container: GridContainer = $PanelContainer/GridContainer

## The export var declaration
@export var slot_count := 5
@export var slot_scene : PackedScene

## The basic var declaration
var hud : Hud
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

func _on_slot_left_clicked(slot: Slot) -> void:
	if slot.slot_data == null or slot.slot_data.is_empty():
		return
	## Shift + leftclick → try to move the item to inventory
	if Input.is_key_pressed(KEY_SHIFT):
		try_move_item_to_inventory(slot)
		return

func try_move_item_to_inventory(slot: Slot) -> void:
	if not hud or not hud.inventory or not hud.inventory.visible:
		return
	
	var slot_data: SlotData = slot.slot_data.copy()
	if slot_data == null or slot_data.is_empty(): return
	
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
