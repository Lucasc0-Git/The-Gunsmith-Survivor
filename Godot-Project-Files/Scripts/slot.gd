extends Panel
class_name Slot
## Handles the drag & drop for the items

## The @onready var declaration
@onready var slot_texture: TextureRect = $TextureRect
@onready var hotbar_slot_number := $HotbarSlotNumber
@onready var amount_counter: Label = $ItemStackCounter


var slot_data: SlotData = null:
	get:
		return _slot_data
	set(value):
		_slot_data = value
		_update_visual()

## The export var declaration
#var amount: int = 0:
	#get:
		#return _amount
	#set(value):
		#_amount = value
		#_update_visual()
#
#var item_data : ItemData = null:
	#get:
		#return _item_data
	#set(value):
		#_item_data = value
		#_update_visual()

## The basic var declaration
var drop_accepted := false
var _slot_data: SlotData = null
#var _amount: int = 0
#var _item_data : ItemData

## The signals declaration
signal item_changed(slot_data: SlotData)
signal mouse_entered_slot(slot_data: SlotData)
signal mouse_exited_slot()
signal slot_left_clicked(slot: Slot)

func _ready() -> void:
	amount_counter.visible = true
	hotbar_slot_number.visible = false
	_update_visual()
	slot_texture.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	slot_texture.connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func set_slot_data(data: SlotData) -> void:
	slot_data = data
	_update_visual()

func set_hotbar_number(index: int) -> void:
	hotbar_slot_number.visible = true
	hotbar_slot_number.text = str(index)

func _update_visual() -> void:
	if slot_data == null or slot_data.is_empty():
		slot_texture.texture = null
		amount_counter.text = ""
		return
	
	slot_texture.texture = slot_data.item_data.icon
	
	if slot_data.amount > 1:
		amount_counter.text = str(slot_data.amount)
	else:
		amount_counter.text = ""

## Called when the player starts dragging some slot
func _get_drag_data(_at_position: Vector2) -> Variant:
	if slot_data == null or slot_data.is_empty(): #If the slot doesn't contain anything, return
		return null
	slot_texture.visible = false #Turn the slot_texture invisible
	amount_counter.visible = false
	##Sets the preview of the drag action
	var preview := TextureRect.new()
	preview.texture = slot_data.item_data.icon
	preview.expand = true
	preview.custom_minimum_size = Vector2(48, 48)
	set_drag_preview(preview)
	## Returns some values
	return {
		"slot_data": slot_data,
		"from_slot": self
	}

func _on_mouse_entered() -> void:
	if slot_data.item_data != null:
		emit_signal("mouse_entered_slot", slot_data)

func _on_mouse_exited() -> void:
	emit_signal("mouse_exited_slot")

## Called at the drop
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("item_data")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	drop_accepted = true
	var from_slot : Slot = data["from_slot"]
	slot_texture.visible = true
	amount_counter.visible = true
	
	if from_slot == self:
		return
	
	if from_slot is Slot:
		swap_items(from_slot)
		emit_signal("item_changed", slot_data)
		from_slot.emit_signal("item_changed", from_slot.slot_data)
	else:
		set_item(data["slot_data"])
		if data.has("from_slot") and data["from_slot"] is Slot:
			data["from_slot"].clear()
		emit_signal("item_changed", slot_data)

## Swaps the whole data of each slot (item)
func swap_items(other_slot: Slot) -> void:
	var temp_slot_data := slot_data
	slot_data = other_slot.slot_data
	other_slot.slot_data = temp_slot_data
	
	if slot_data != null or !slot_data.is_empty():
		slot_texture.texture = slot_data.item_data.icon
	else:
		slot_texture.texture = null
	
	other_slot.amount_counter.visible = true
	if other_slot.item_data != null:
		other_slot.slot_texture.texture = other_slot.item_data.icon
	else:
		other_slot.slot_texture.texture = null

func set_item(item: ItemData, amount: int = 1) -> void:
	if slot_data == null:
		slot_data = SlotData.new()
	slot_data.item_data = item
	slot_data.amount = amount
	_update_visual()
	emit_signal("item_changed", slot_data)

func clear() -> void:
	if slot_data:
		slot_data.clear()
	_update_visual()
	emit_signal("item_changed", slot_data)

func add_amount(value: int) -> void:
	if slot_data:
		slot_data.amount += value
		_update_visual()
		emit_signal("item_changed", slot_data)

func remove_amount(value: int) -> void:
	if slot_data:
		slot_data.amount -= value
		if slot_data.amount <= 0:
			slot_data.clear()
		_update_visual()
		emit_signal("item_changed", slot_data)

## Monitors the notifications (dont know what is it), pretty much temporary solution
func _notification(what: int) -> void:
	## If the drag fails, call on_drop_failed()
	if what == NOTIFICATION_DRAG_END:
		if not drop_accepted:
			on_drop_failed()
		drop_accepted = false

## Called when the drop fails
func on_drop_failed() -> void:
	slot_texture.visible = true

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		slot_left_clicked.emit(self)
	
	#if event is InputEventMouseButton \
	#and event.button_index == MOUSE_BUTTON_RIGHT \
	#and event.pressed \
	#and item_data != null:
		#item_used.emit(item_data)
