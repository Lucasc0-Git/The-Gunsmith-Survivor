extends Panel
class_name Slot
## Handles the drag & drop for the items

## The @onready var declaration
@onready var slot_texture: TextureRect = $TextureRect
@onready var hotbar_slot_number := $HotbarSlotNumber
@onready var item_count_label := $ItemStackCounter

## The basic var declaratio
var item_data : ItemData = null
var drop_accepted := false

## The signals declaration
signal item_changed(items: ItemData)
signal mouse_entered_slot(item_data: ItemData)
signal mouse_exited_slot()
signal slot_left_clicked(slot: Slot)

func _ready() -> void:
	hotbar_slot_number.visible = false
	item_count_label.visible = false
	slot_texture.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	slot_texture.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	

func set_hotbar_number(index: int) -> void:
	hotbar_slot_number.visible = true
	hotbar_slot_number.text = str(index)

## Called when the player starts dragging some slot
func _get_drag_data(_at_position: Vector2) -> Variant:
	if item_data == null: #If the slot doesn't contain anything, return
		return null
	
	slot_texture.visible = false #Turn the slot_texture invisible
	##Sets the preview of the drag action
	var preview := TextureRect.new()
	preview.texture = item_data.icon
	preview.expand = true
	preview.custom_minimum_size = Vector2(48, 48)
	set_drag_preview(preview)
	## Returns some values
	return {
		"item_data": item_data,
		"from_slot": self
	}

func _on_mouse_entered() -> void:
	if item_data != null:
		emit_signal("mouse_entered_slot", item_data)

func _on_mouse_exited() -> void:
	emit_signal("mouse_exited_slot")

## Called at the drop
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("item_data")

## Called if the drop succeded
#func _drop_data(_at_position: Vector2, data: Variant) -> void:
	#drop_accepted = true
	#var from_slot : Panel = data["from_slot"]
	#slot_texture.visible = true
	#if from_slot == self: #If dropping in the same slot, return
		#return
	#
	#swap_items(from_slot)
	#item_changed.emit(item_data)

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	drop_accepted = true
	var from_slot : Slot = data["from_slot"]
	slot_texture.visible = true
	
	if from_slot == self:
		return
	
	if from_slot is Slot:
		swap_items(from_slot)
		emit_signal("item_changed", item_data)
		from_slot.emit_signal("item_changed", from_slot.item_data)
	else:
		set_item(data["item_data"])
		if data.has("from_slot") and data["from_slot"] is Slot:
			data["from_slot"].clear()
		emit_signal("item_changed", item_data)

## Swaps the whole data of each slot (item)
func swap_items(other_slot: Slot) -> void:
	var temp_data := item_data
	item_data = other_slot.item_data
	other_slot.item_data = temp_data
	
	if item_data != null:
		slot_texture.texture = item_data.icon
	else:
		slot_texture.texture = null
	
	if other_slot.item_data != null:
		other_slot.slot_texture.texture = other_slot.item_data.icon
	else:
		other_slot.slot_texture.texture = null

func set_item(new_item: ItemData) -> void:
	item_data = new_item
	if item_data != null:
		slot_texture.texture = item_data.icon
	else:
		slot_texture.texture = null
	emit_signal("item_changed", item_data)

func clear() -> void:
	set_item(null)

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
