extends Control
class_name BasicCraftingUI

@onready var grid_container: GridContainer = $PanelContainer/GridContainer
@onready var the_core: TheCore
@onready var inventory: Inventory
@onready var basic_craftings: BasicCraftingUIPanel = $BasicCraftingPanels

@onready var glock_button: Button = $BasicCraftingPanels/VBoxContainer/Control/WeaponsCraftingContainer/MarginContainer/ScrollContainer/HBoxContainer/Glock
@onready var shotgun_button: Button = $BasicCraftingPanels/VBoxContainer/Control/WeaponsCraftingContainer/MarginContainer/ScrollContainer/HBoxContainer/Shotgun


var crafting_buttons: Dictionary[Button, ItemData] = {} # Button -> ItemData

var glock_item: ItemData = ItemRegistry.items["glock"]
var wood_item: ItemData = ItemRegistry.items["wood"]
var shotgun_item: ItemData = ItemRegistry.items["shotgun"]

var _tween: Tween
var player: Player
var crafting_shown: bool = false

func _ready() -> void:
	for i in range(grid_container.get_child_count()):
		var crafting_slot: Button = grid_container.get_child(i)
		crafting_slot.toggled.connect(
			func(toggled_on: bool, idx: int = i) -> void: _on_button_toggled(toggled_on, idx)
		)
	
	await get_tree().process_frame
	the_core = get_tree().get_first_node_in_group("thecore")
	player = the_core.main.player
	
	#the_core.player_entered_crafting_area.connect(show_crafting)
	#the_core.player_exited_crafting_area.connect(hide_crafting)
	
	## When adding more craftable items, need to add here.
	crafting_buttons[glock_button] = glock_item
	crafting_buttons[shotgun_button] = shotgun_item
	
	if inventory == null:
		push_error("Inventory is null")


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

func _process(_delta: float) -> void:
	if visible:
		for button: Button in crafting_buttons.keys():
			var item: ItemData = crafting_buttons[button]
			button.disabled = !inventory.can_craft(item.crafting_recipe)
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
		inventory.give_item(glock_item)
		inventory.rm_items_by_recipe(glock_item.crafting_recipe)

func _on_shotgun_pressed() -> void:
	if inventory == null: return
	if inventory.can_craft(shotgun_item.crafting_recipe):
		inventory.give_item(shotgun_item)
		inventory.rm_items_by_recipe(shotgun_item.crafting_recipe)

##The Tools crafting recipes.

##The Stations crafting recipes.
