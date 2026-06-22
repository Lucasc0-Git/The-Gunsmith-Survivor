extends PanelContainer
class_name RightClickTooltip

@onready var split_button: Button = $MarginContainer/VBoxContainer/Split
@onready var drop_button: Button = $MarginContainer/VBoxContainer/Drop
@onready var hud: Hud = get_parent()

var operating_slot: Slot = null
var is_slot_in_inventory: bool = false

func _ready() -> void:
	hide()

func _on_drop_pressed() -> void:
	if !operating_slot: return
	var index: int = operating_slot.get_index()
	if is_slot_in_inventory:
		hud.player.drop_inventory_item(index)
	else:
		hud.player.drop_hotbar_item(index)
	hide_tooltip()
	#hud.player.drop_inventory_item()

func _input(event: InputEvent) -> void:
	if !visible:
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var global_rect := get_global_rect()
		if not global_rect.has_point(get_global_mouse_position()):
			hide_tooltip()
			accept_event()
			return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E or event.keycode == KEY_ESCAPE:
			hide_tooltip()
			accept_event()
			return

func _on_split_pressed() -> void:
	if !operating_slot: return
	if is_slot_in_inventory:
		hud.inventory.slot_split(operating_slot)
	else:
		hud.hotbar.split_slot(operating_slot)
	
	hide_tooltip()

func hide_tooltip() -> void:
	hide()
	operating_slot = null

func show_tooltip(slot: Slot, pos: Vector2, from_inventory: bool) -> void:
	if slot.slot_data.is_empty(): return
	global_position = pos + Vector2(45, 20)
	show()
	operating_slot = slot
	is_slot_in_inventory = from_inventory
