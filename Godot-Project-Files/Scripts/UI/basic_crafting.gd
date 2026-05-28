extends Control
class_name BasicCraftingUI

@onready var grid_container: GridContainer = $PanelContainer/GridContainer
@onready var the_core: TheCore
@onready var inventory: Inventory
@onready var hud: Hud
@onready var basic_craftings: BasicCraftingUIPanel = $BasicCraftingPanels

@onready var glock_button: Button = $BasicCraftingPanels/VBoxContainer/Control/WeaponsCraftingContainer/MarginContainer/ScrollContainer/HBoxContainer/Glock
@onready var shotgun_button: Button = $BasicCraftingPanels/VBoxContainer/Control/WeaponsCraftingContainer/MarginContainer/ScrollContainer/HBoxContainer/Shotgun
@onready var basic_station_button: Button = $BasicCraftingPanels/VBoxContainer/Control3/CraftingStationsCraftingContainer3/MarginContainer/ScrollContainer/HBoxContainer/BasicStation
@onready var torch_button: Button = $BasicCraftingPanels/VBoxContainer/Control4/BaseCraftingContainer3/MarginContainer/ScrollContainer/HBoxContainer/Torch
@onready var wooden_axe_button: Button = $BasicCraftingPanels/VBoxContainer/Control2/ToolsCraftingContainer2/MarginContainer/ScrollContainer/HBoxContainer/WoodenAxe
@onready var assault_rifle_button: Button = $BasicCraftingPanels/VBoxContainer/Control/WeaponsCraftingContainer/MarginContainer/ScrollContainer/HBoxContainer/AssaultRifle
@onready var basic_smithing_table_button: Button = $BasicCraftingPanels/VBoxContainer/Control3/CraftingStationsCraftingContainer3/MarginContainer/ScrollContainer/HBoxContainer/BasicSmithingTable


var crafting_buttons: Dictionary[Button, ItemData] = {} # Button -> ItemData

var glock_item: ItemData
var wood_item: ItemData
var shotgun_item: ItemData
var torch_item: ItemData
var apple_item: ItemData
var basic_station_item: ItemData
var wooden_axe_item: ItemData
var assault_rifle_item: ItemData
var basic_smithing_table_item: ItemData

var _tween: Tween
var player: Player
var crafting_shown: bool = false
var main: Main = GameManager.main

func _ready() -> void:
	if not ItemRegistry or not ItemRegistry.loaded:
		await ItemRegistry.items_loaded
	while !GameManager.is_game_loaded:
		await get_tree().process_frame
	
	glock_item = ItemRegistry.items.get("glock")
	shotgun_item = ItemRegistry.items.get("shotgun")
	apple_item = ItemRegistry.items.get("apple")
	wood_item = ItemRegistry.items.get("wood")
	torch_item = ItemRegistry.items.get("torch")
	basic_station_item = ItemRegistry.items.get("basic_station")
	wooden_axe_item = ItemRegistry.items.get("wooden_axe")
	assault_rifle_item = ItemRegistry.items.get("assault_rifle")
	basic_smithing_table_item = ItemRegistry.items.get("basic_smithing_table")
	
	
	for i in range(grid_container.get_child_count()):
		var crafting_slot: Button = grid_container.get_child(i)
		crafting_slot.toggled.connect(
			func(toggled_on: bool, idx: int = i) -> void: _on_button_toggled(toggled_on, idx)
		)
	
	main = GameManager.main
	the_core = main.the_core
	player = main.player
	hud = main.hud
	
	if !main: push_error("BasicCrafting: Main is null!")
	if !the_core: push_error("BasicCrafting: TheCore is null!")
	if !player: push_error("BasicCrafting: Player is null!")
	if !hud: push_error("BasicCrafting: HUD is null!")
	
	
	## When adding more craftable items, need to add here.
	crafting_buttons[glock_button] = glock_item
	crafting_buttons[shotgun_button] = shotgun_item
	crafting_buttons[basic_station_button] = basic_station_item
	crafting_buttons[torch_button] = torch_item
	crafting_buttons[wooden_axe_button] = wooden_axe_item
	crafting_buttons[assault_rifle_button] = assault_rifle_item
	crafting_buttons[basic_smithing_table_button] = basic_smithing_table_item


func hide_crafting() -> void:
	if _tween: _tween.kill()
	crafting_shown = false
	for crafting_slot in grid_container.get_children():
		crafting_slot.mouse_filter = MOUSE_FILTER_IGNORE
		crafting_slot.button_pressed = false
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN)
	_tween.set_trans(Tween.TRANS_BACK)
	_tween.tween_property(self, "global_position", Vector2(-84.0, 122.0), 0.5)
	await _tween.finished
	visible = false

func show_crafting() -> void:
	if _tween: _tween.kill()
	crafting_shown = true
	for crafting_button in grid_container.get_children():
		crafting_button.mouse_filter = MOUSE_FILTER_PASS
		crafting_button.button_pressed = false
	visible = true
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(self, "global_position", Vector2(10.0, 122.0), 0.5)

func _on_button_toggled(toggled_on: bool, index: int) -> void:
	if index == 0:
		basic_craftings.toggle_weapons_crafting(toggled_on)
	elif index == 1:
		basic_craftings.toggle_tools_crafting(toggled_on)
	elif index == 2:
		basic_craftings.toggle_stations_crafting(toggled_on)
	elif index == 3:
		basic_craftings.toggle_base_crafting(toggled_on)

func _process(_delta: float) -> void:
	if !GameManager.is_game_loaded: return
	if visible:
		for button: Button in crafting_buttons.keys():
			var item: ItemData = crafting_buttons[button]
			if item:
				var can_craft := inventory.can_craft(item.crafting_recipe)
				var has_station_types := GameManager.has_required_stations(item)
				if can_craft and has_station_types:
					button.disabled = false
				else:
					button.disabled = true
	if !crafting_shown:
		if !player.nearby_stations.is_empty():
			show_crafting()
	if crafting_shown:
		if player.nearby_stations.is_empty():
			hide_crafting()

##The Weapons crafting recipes.

func _on_glock_pressed() -> void:
	if inventory == null: return
	if inventory.can_craft(glock_item.crafting_recipe):
		hud.give_item(glock_item)
		inventory.rm_items_by_recipe(glock_item.crafting_recipe)

func _on_shotgun_pressed() -> void:
	if inventory == null: return
	if inventory.can_craft(shotgun_item.crafting_recipe):
		hud.give_item(shotgun_item)
		inventory.rm_items_by_recipe(shotgun_item.crafting_recipe)

func _on_assault_rifle_pressed() -> void:
	if inventory == null: return
	if inventory.can_craft(assault_rifle_item.crafting_recipe):
		hud.give_item(assault_rifle_item)
		inventory.rm_items_by_recipe(assault_rifle_item.crafting_recipe)

##The Tools crafting recipes.

func _on_wooden_axe_pressed() -> void:
	if !inventory: return
	if inventory.can_craft(wooden_axe_item.crafting_recipe):
		hud.give_item(wooden_axe_item)
		inventory.rm_items_by_recipe(wooden_axe_item.crafting_recipe)

##The Stations crafting recipes.

func _on_basic_station_pressed() -> void:
	if inventory == null: return
	if inventory.can_craft(basic_station_item.crafting_recipe):
		hud.give_item(basic_station_item)
		inventory.rm_items_by_recipe(basic_station_item.crafting_recipe)

func _on_basic_smithing_table_pressed() -> void:
	if inventory == null: return
	if inventory.can_craft(basic_smithing_table_item.crafting_recipe):
		hud.give_item(basic_smithing_table_item)
		inventory.rm_items_by_recipe(basic_smithing_table_item.crafting_recipe)

##The Base crafting recipes.

func _on_torch_pressed() -> void:
	if inventory == null: return
	if inventory.can_craft(torch_item.crafting_recipe):
		hud.give_item(torch_item)
		inventory.rm_items_by_recipe(torch_item.crafting_recipe)
