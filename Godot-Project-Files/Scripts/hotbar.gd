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
signal slot_item_changed(index: int, item: ItemData, amount: int)

func _ready() -> void:
	for i in range(slot_count): ##Add slots to hotbar
		var index := i
		var slot := slot_scene.instantiate()
		## Connect signals
		slot.item_changed.connect(
			func(item: ItemData, amount: int, idx := index) -> void:
				_on_slot_item_changed(idx, item, amount)
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
			var data_slot := hud.player.hotbar_slots[i]
			
			slots[i].item_data = data_slot.item_data
			slots[i].amount = data_slot.amount

func _on_slot_left_clicked(slot: Slot) -> void:
	if slot.item_data == null:
		return
	## Shift + leftclick → try to move the item to inventory
	if Input.is_key_pressed(KEY_SHIFT):
		try_move_item_to_inventory(slot)
		return

func try_move_item_to_inventory(slot: Slot) -> void:
	if not hud or not hud.inventory or not hud.inventory.visible:
		return
	var item := slot.item_data
	if item == null:
		return
	## Find the first free slot in inventory
	for inv_slot in hud.inventory.grid_container.get_children():
		if inv_slot.item_data == null:
			inv_slot.set_item(item)
			slot.clear()
			var index := slots.find(slot) 
			slot_item_changed.emit(index, null)
			return

func clear_selected_slot() -> void:
	var slot := slots[selected_slot_index]
	slot.clear()
	slot_item_changed.emit(selected_slot_index, null)

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

func set_item(index: int, item: ItemData, amount: int) -> void:
	slots[index].set_item(item, amount)

func _on_slot_item_changed(index: int, item: ItemData, amount: int) -> void:
	slot_item_changed.emit(index, item, amount)
	if hud and hud.player:
		hud.player.set_hotbar_item(index, item, amount)
