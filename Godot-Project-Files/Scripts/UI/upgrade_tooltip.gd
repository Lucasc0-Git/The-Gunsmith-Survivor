extends RichTextLabel
class_name UpgradeTooltip

@onready var hud: Hud = get_parent()




func _ready() -> void:
	hide()

func show_tooltip(slot_data: SlotData) -> void:
	if slot_data == null: return
	if slot_data.is_empty(): return
	if not slot_data.item_data is WeaponItemData: return
	var weapon_data: WeaponData = slot_data.item_data.weapon_data
	
	var bb: String = ""
	var level: int = slot_data.level
	var base_dmg: float = weapon_data.damage
	var base_fire_rate: float = weapon_data.fire_rate
	
	var old_dmg: float = base_dmg * Player.get_damage_multiplier(level)
	var new_dmg: float = base_dmg * Player.get_damage_multiplier(level + 1)
	
	var old_fire_rate: float = max(base_fire_rate * Player.get_fire_rate_multiplier(level), base_fire_rate * 0.3)
	var new_fire_rate: float = max(base_fire_rate * Player.get_fire_rate_multiplier(level + 1), base_fire_rate * 0.3)
	
	
	bb += "[b]Upgrading: " + slot_data.item_data.display_name + "[/b]\n"
	bb += "Level: %d → [color=green]%d[/color]\n\n" % [level, level + 1]
	
	if old_dmg != new_dmg:
		bb += "Damage: %.0f → [color=green]%.0f[/color]\n" % [old_dmg, new_dmg]
	else:
		bb += "Damage: %.0f" % [old_dmg]
	
	if old_fire_rate != new_fire_rate:
		bb += "Fire Rate: %.2f → [color=green]%.2f[/color]\n" % [old_fire_rate, new_fire_rate]
	else:
		bb += "Fire Rate: %.2f" % [old_fire_rate]
	
	bb += "\n"
	bb += "[b]Needed items:[/b]\n"
	var needed_items: Dictionary = hud.player.get_needed_upgrade_materials(slot_data.item_data, level)
	for item: ItemData in needed_items:
		var player_has_item: bool = true if hud.inventory.find_item(item) >= needed_items[item] else false
		bb += "%s%s%s - " % [has_enough(player_has_item), item.display_name, "[/color]"] + str(needed_items[item]) + "\n"
	
	
	visible = true
	bbcode_enabled = true
	text = bb
	
	size = get_minimum_size()
	
	_update_position()

func hide_tooltip() -> void:
	hide()

func has_enough(has: bool) -> String:
	if has:
		return "[color=green]"
	else:
		return "[color=red]"

func _update_position() -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	var tooltip_size : Vector2= size
	var viewport_size : Vector2 = get_viewport().get_visible_rect().size
	
	var x := mouse_pos.x + 10
	var y := mouse_pos.y + 10
	if x + tooltip_size.x > viewport_size.x:
		x = viewport_size.x - tooltip_size.x - 5
	if y + tooltip_size.y > viewport_size.y:
		y = viewport_size.y - tooltip_size.y - 5
	
	global_position = Vector2(x, y)

func _process(_delta: float) -> void:
	
	if visible:
		_update_position()
