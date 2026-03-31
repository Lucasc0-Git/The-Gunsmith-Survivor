extends RichTextLabel
class_name CraftingTooltip

## The onready var declaration
@onready var hud: Hud = get_parent().get_parent().get_parent()

## The basic var declaration
var basic_crafting: BasicCraftingUI = get_parent()

func _ready() -> void:
	var font_variation := FontVariation.new()
	font_variation.base_font = self.get_theme_font("normal_font")
	font_variation.spacing_glyph = 0
	self.add_theme_font_override("normal_font", font_variation)

func show_tooltip(item_data: ItemData) -> void:
	if item_data == null: return
	var bb : String = ""
	
	bb += "[b][i]" + "         " + "Craft:" + "[/i][/b]\n"
	bb += "[b]" + str(item_data.display_name) + "[/b]\n"
	if item_data.crafting_description == "":
		bb += str(item_data.description) + "\n"
	else:
		bb += str(item_data.crafting_description) + "\n"
	
	if item_data is WeaponItemData:
		bb += "-Damage: " + str(item_data.weapon_data.damage) + "\n"
	elif item_data is HealItemData:
		bb += "-HealPowah: " + str(item_data.heal_data.heal) + " "
		if item_data.heal_data.over_time_heal:
			bb += "over " + str(item_data.heal_data.time_healing) + "\n"
		else:
			bb += "\n"
	elif item_data is JustItemData:
		pass #Does nothing
	
	bb += "\n"
	bb += "[b]" + "Crafting requirements:" + "[/b]\n"
	var crafting_recipe: Dictionary[ItemData, int] = item_data.crafting_recipe
	for item in crafting_recipe:
		bb += str(crafting_recipe[item]) + "x " + str(item.display_name) + "\n"
	
	visible = true
	self.bbcode_text = bb
	
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
