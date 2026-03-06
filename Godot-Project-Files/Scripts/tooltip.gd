extends RichTextLabel
class_name Tooltip

## The onready var declaration
@onready var hud: Hud = get_parent()

## The basic var declaration
var inventory: Inventory

func _ready() -> void:
	var font_variation := FontVariation.new()
	font_variation.base_font = self.get_theme_font("normal_font")
	font_variation.spacing_glyph = 0
	self.add_theme_font_override("normal_font", font_variation)

func show_tooltip(slot_data: SlotData) -> void:
	if slot_data.is_empty(): return
	var bb : String = ""
	bb += "[b]" + slot_data.item_data.display_name + "[/b]\n"
	bb += slot_data.item_data.description + "\n\n"
	if slot_data.item_data is WeaponItemData:
		bb += "Damage: " + str(slot_data.item_data.weapon_data.damage) + " hp" + "\n"
		bb += "Fire rate: " + str(slot_data.item_data.weapon_data.fire_rate) + "\n"
	elif slot_data.item_data is HealItemData:
		bb += "Heal: " + str(slot_data.item_data.heal_data.heal) + " hp" + "\n"
	elif slot_data.item_data is JustItemData:
		pass
	
	
	visible = true
	self.bbcode_text = bb
	
	size = get_minimum_size()
	
	var mouse_pos := get_viewport().get_mouse_position()
	var tooltip_size : Vector2 = size
	var viewport_size : Vector2 = get_viewport().get_visible_rect().size
	
	var x := mouse_pos.x + 10
	var y := mouse_pos.y + 10
	if x + tooltip_size.x > viewport_size.x:
		x = viewport_size.x - tooltip_size.x - 5
	if y + tooltip_size.y > viewport_size.y:
		y = viewport_size.y - tooltip_size.y - 5
	global_position = Vector2(x, y)

func hide_tooltip() -> void:
	visible = false

func _process(_delta: float) -> void:
	if visible:
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
