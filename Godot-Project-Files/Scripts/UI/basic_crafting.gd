extends Control
class_name BasicCraftingUI

@onready var grid_container: GridContainer = $PanelContainer/GridContainer
@onready var the_core: TheCore
@onready var inventory: Inventory
@onready var hud: Hud
@onready var basic_craftings: BasicCraftingUIPanel = $BasicCraftingPanels

var crafting_buttons: Dictionary[ItemCraftingButton, ItemData] = {} # Button -> ItemData
var crafting_items: Dictionary[String, ItemData] = {} #ItemData.id -> ItemData

var _tween: Tween
var player: Player
var crafting_shown: bool = false
var main: Main = GameManager.main

func _ready() -> void:
	if not ItemRegistry or not ItemRegistry.loaded:
		await ItemRegistry.items_loaded
	while !GameManager.is_game_loaded:
		await get_tree().process_frame
	
	for i in range(grid_container.get_child_count()):
		var crafting_slot: Button = grid_container.get_child(i)
		crafting_slot.toggled.connect(
			func(toggled_on: bool, idx: int = i) -> void: _on_button_toggled(toggled_on, idx)
		)
	for child in get_all_children(basic_craftings):
		if child is ItemCraftingButton:
			if !child.item_data: continue
			print(str(child))
			crafting_buttons[child as ItemCraftingButton] = child.item_data
			child.crafting_button_pressed.connect(_on_item_craft_button_pressed)
			crafting_items[child.item_data.id] = child.item_data
			child.mouse_entered.connect(func () -> void: basic_craftings._on_item_button_mouse_entered(child.item_data))
			child.mouse_exited.connect(basic_craftings._on_item_button_mouse_exited)
	
	main = GameManager.main
	the_core = main.the_core
	player = main.player
	hud = main.hud
	
	if !main: push_error("BasicCrafting: Main is null!")
	if !the_core: push_error("BasicCrafting: TheCore is null!")
	if !player: push_error("BasicCrafting: Player is null!")
	if !hud: push_error("BasicCrafting: HUD is null!")
	

func get_all_children(node: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	for child in node.get_children():
		nodes.append(child)
		nodes.append_array(get_all_children(child))
	return nodes

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
	AudioManager.play_sfx("crafting_sound")
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
		for button: ItemCraftingButton in crafting_buttons.keys():
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

func _on_item_craft_button_pressed(item_data: ItemData) -> void:
	AudioManager.play_sfx("crafting_sound")
	if inventory == null: return
	if inventory.can_craft(item_data.crafting_recipe):
		hud.give_item(item_data)
		inventory.rm_items_by_recipe(item_data.crafting_recipe)
		GameManager.more_stats["Items crafted"] += 1
		GameManager.show_score_popup("Item Crafted: Score +%s" % [item_data.score_for_crafting])
		GameManager.score += item_data.score_for_crafting
