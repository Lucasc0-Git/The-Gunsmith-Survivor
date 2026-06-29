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
	if !GameManager.is_game_loaded: return
	if item_data == null: return
	var bb : String = ""
	
	# Header
	#bb += "[b][i] Craft:" + "[/i][/b]\n"
	bb += "[b]" + str(item_data.display_name) + "[/b]\n"
	# Description
	if item_data.crafting_description == "":
		bb += str(item_data.description) + "\n"
	else:
		bb += str(item_data.crafting_description) + "\n"
	
	# Weapon stats
	if item_data is WeaponItemData:
		bb += "[ul]\n"
		bb += "Damage: " + str(item_data.weapon_data.damage) + "\n"
		if item_data.weapon_data.heated:
			bb += "Heated weapon\n"
		bb += "[/ul]\n"
	
	# Heal stats
	elif item_data is HealItemData:
		bb += "[ul]\n"
		bb += "[*]HealPower: " + str(item_data.heal_data.heal)
		if item_data.heal_data.over_time_heal:
			bb += " over " + str(item_data.heal_data.time_healing) + "s"
		bb += "\n"
		bb += "[/ul]\n"
	
	# just...
	elif item_data is JustItemData:
		pass #Does nothing
	
	bb += "\n"
	
	# Crafting requirements
	bb += "[b]" + "Crafting requirements:" + "[/b]\n"
	var crafting_recipe: Dictionary[ItemData, int] = item_data.crafting_recipe
	
	if not crafting_recipe.is_empty():
		bb += "[ul]\n"
		for ingredient: ItemData in crafting_recipe:
			var needed := crafting_recipe[ingredient]
			var color_prefix := text_color(has_enough(ingredient, needed))
			bb += color_prefix + str(needed) + "x " + ingredient.display_name
			if color_prefix != "":
				bb += "[/color]"
			bb += "\n"
		bb += "[/ul]\n"
	
	# Needed stations
	bb += "[b]" + "Needed crafting stations:" + "[/b]\n"
	var needed_stations: Dictionary[GameManager.StationType, int] = item_data.needed_stations
	
	if not needed_stations.is_empty():
		bb += "[ul]\n"
		for station_type: GameManager.StationType in needed_stations.keys():
			var station_name := GameManager.get_station_name(station_type)
			var color_prefix := text_color(has_station(station_type))
			bb += color_prefix + station_name
			if color_prefix != "":
				bb += "[/color]"
			bb += "\n"
		bb += "[/ul]\n"
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

func has_station(station_type: GameManager.StationType) -> bool:
	if GameManager.has_this_station(station_type):
		return true
	return false

func has_enough(ingredient: ItemData, required_amount: int) -> bool:
	var current_amount := hud.inventory.find_item(ingredient)
	return current_amount >= required_amount

func text_color(correct: bool) -> String:
	if correct:
		return ""
	return "[color=red]"

func hide_tooltip() -> void:
	visible = false

func _process(_delta: float) -> void:
	if !GameManager.is_game_loaded: return
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
