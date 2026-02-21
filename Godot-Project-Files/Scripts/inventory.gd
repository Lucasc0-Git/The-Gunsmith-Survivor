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
var inv_slot : Panel
var player: Player
var hud : Hud

## The signal declaration
signal item_used(item: ItemData)

func _ready() -> void:
	## Assign proper data to proper items
	glock_item = ItemRegistry.items["glock"]
	shotgun_item = ItemRegistry.items["shotgun"]
	apple_item = ItemRegistry.items["apple"]
	
	visible = false
	
	## Give the inventory some slots
	for i in range(20): #The range is how much slots will the inventory have
		var slot := slot_scene.instantiate()
		slot.slot_left_clicked.connect(_on_slot_left_click)
		grid_container.add_child(slot) #add the slot as child to grid_container
	## Connect tooltip signals from all the slots
	for slot in grid_container.get_children():
		slot.connect("mouse_entered_slot", Callable(self, "_show_tooltip"))
		slot.connect("mouse_exited_slot", Callable(self, "_hide_tooltip"))
	# Give some slots some items for debugging, needs to be removed after debugging
	fill_slot(0, glock_item)
	fill_slot(1, shotgun_item)
	fill_slot(2, apple_item)
	fill_slot(3, apple_item)
	fill_slot(4, apple_item)
	fill_slot(5, apple_item)

func _on_item_used(item: ItemData) -> void:
	item_used.emit(item)

func _on_slot_left_click(slot: Slot) -> void:
	if slot.item_data == null:
		return
	## Shift + leftclick → try to move the item to hotbar
	if Input.is_key_pressed(KEY_SHIFT):
		move_item_to_hotbar(slot)
		return
	# Jinak můžeš volit standardní "use item" akci
	#emit_signal("item_used", slot.item_data)

func move_item_to_hotbar(slot: Slot) -> void:
	var item := slot.item_data
	if not player:
		return
	# Najdi první volné místo v hotbaru
	for i in range(player.hotbar_slots.size()):
		if player.hotbar_slots[i] == null:
			# Přesuň item
			player.hotbar_slots[i] = item
			hud.hotbar.set_item(i, item)  # vizuální update hotbaru
			# Vymaž slot v inventáři
			slot.item_data = null
			slot.slot_texture.texture = null
			slot.item_changed.emit(null)  # aby signály věděly o změně
			return

func fill_slot(slot: int, item: ItemData) -> void:
	inv_slot = grid_container.get_child(slot)
	inv_slot.item_data = item
	inv_slot.slot_texture.texture = item.icon

func _show_tooltip(item_data: ItemData) -> void:
	tooltip.show_tooltip(item_data)

func _hide_tooltip() -> void:
	tooltip.hide_tooltip()
