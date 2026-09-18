extends PanelContainer
class_name RightClickTooltip

@onready var split_button: Button = $MarginContainer/VBoxContainer/Split
@onready var drop_button: Button = $MarginContainer/VBoxContainer/Drop
@onready var upgrade_button: Button = $MarginContainer/VBoxContainer/UpgradeButton
@onready var hud: Hud = get_parent()
@onready var upgrade_tooltip: UpgradeTooltip = %UpgradeTooltip


var operating_slot: Slot = null
var is_slot_in_inventory: bool = false

func _ready() -> void:
	hide()

func _on_drop_pressed() -> void:
	if !operating_slot: return
	AudioManager.play("button_click", -3)
	var index: int = operating_slot.get_index()
	if is_slot_in_inventory:
		hud.player.drop_inventory_item(index)
	else:
		hud.player.drop_hotbar_item(index)
	hide_tooltip()

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
	AudioManager.play("button_click", -3)
	if is_slot_in_inventory:
		hud.inventory.slot_split(operating_slot)
	else:
		hud.hotbar.split_slot(operating_slot)
	
	hide_tooltip()

func hide_tooltip() -> void:
	hide()
	operating_slot = null
	hud.weapon.right_click_tooltip_shown = false

func show_tooltip(slot: Slot, pos: Vector2, from_inventory: bool) -> void:
	if slot.slot_data.is_empty(): return
	hud.weapon.right_click_tooltip_shown = true
	AudioManager.play("button_click", -3)
	global_position = pos + Vector2(45, 20)
	show()
	operating_slot = slot
	is_slot_in_inventory = from_inventory
	
	if operating_slot.slot_data.item_data and operating_slot.slot_data.item_data is WeaponItemData:
		upgrade_button.visible = true
	else:
		upgrade_button.visible = false
	
	size = get_minimum_size()
	
	var mouse_pos := get_viewport().get_mouse_position()
	var tooltip_size : Vector2 = size
	var viewport_size : Vector2 = get_viewport().get_visible_rect().size
	
	var x := mouse_pos.x + 10
	var y := mouse_pos.y + 10
	if x + tooltip_size.x > viewport_size.x:
		x = viewport_size.x - tooltip_size.x - 50
	if y + tooltip_size.y > viewport_size.y:
		y = viewport_size.y - tooltip_size.y - 50
	global_position = Vector2(x, y)

func _on_dismantle_pressed() -> void:
	if !operating_slot: return
	if !operating_slot.slot_data.item_data: return
	AudioManager.play("button_click", -3)
	hud.dismantle_item(operating_slot.slot_data.item_data, operating_slot.slot_data.amount)
	operating_slot.clear()
	hide_tooltip()

func _on_upgrade_button_pressed() -> void:
	if !operating_slot: return
	if operating_slot.slot_data.is_empty(): return
	AudioManager.play("button_click", -3)
	
	if hud.can_upgrade(operating_slot.slot_data):
		var needed_materials: Dictionary[ItemData, int] = {}
		needed_materials.assign(Player.get_needed_upgrade_materials(operating_slot.slot_data.item_data.crafting_recipe, operating_slot.slot_data.level))
		hud.inventory.rm_items_by_recipe(needed_materials)
		operating_slot.slot_data.level += 1
	
	upgrade_tooltip.hide_tooltip()
	upgrade_tooltip.show_tooltip(operating_slot.slot_data)

func _on_upgrade_button_mouse_entered() -> void:
	upgrade_tooltip.show_tooltip(operating_slot.slot_data if operating_slot else null)
func _on_upgrade_button_mouse_exited() -> void:
	upgrade_tooltip.hide_tooltip()
