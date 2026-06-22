extends PanelContainer
class_name RightClickTooltip

@onready var split_button: Button = $MarginContainer/VBoxContainer/SplitVBoxContainer/Split
@onready var drop_button: Button = $MarginContainer/VBoxContainer/DropVBoxContainer/Drop
@onready var hud: Hud = get_parent()

var operating_slot: Slot = null
var is_slot_in_inventory: bool = false

func _ready() -> void:
	visible = false

func _on_drop_pressed() -> void:
	if !operating_slot: return
	var index: int = operating_slot.get_index()
	if is_slot_in_inventory:
		hud.player.drop_inventory_item(index)
	else:
		hud.player.drop_hotbar_item(index)
	hide_tooltip()
	#hud.player.drop_inventory_item()


func _on_split_pressed() -> void:
	if !operating_slot: return
	if is_slot_in_inventory:
		hud.inventory.slot_split(operating_slot)
	else:
		hud.hotbar.split_slot(operating_slot)
	
	hide_tooltip()

func hide_tooltip() -> void:
	visible = false
	operating_slot = null

func show_tooltip(slot: Slot, pos: Vector2, from_inventory: bool) -> void:
	if slot.slot_data.is_empty(): return
	global_position = pos
	visible = true
	operating_slot = slot
	is_slot_in_inventory = from_inventory
