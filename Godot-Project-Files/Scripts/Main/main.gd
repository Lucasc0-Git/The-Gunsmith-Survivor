extends Node2D
class_name Main

## The @onready var declaration
@onready var hud: Hud = $HUD
@onready var map: Map = $Map
@onready var menu: CanvasLayer = $Menu
@onready var Ysort := $YSORT
@onready var label: Label = $CanvasLayer/Label
@onready var spawners: Node2D = $Spawners
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var cheat_mode_label: Label = $CanvasLayer/CheatMode
@onready var respawn_timers: Node2D = $RespawnTimers

enum TimeOfDay {DAWN, SUNRISE, DAY, SUNSET, DUSK, NIGHT}

@export var lighting_colors: Array[Color] = [
	Color(0.4, 0.4, 0.6),  # DAWN
	Color(0.7, 0.6, 0.5),  # SUNRISE
	Color(1, 1, 1),         # DAY
	Color(0.7, 0.6, 0.5),  # SUNSET
	Color(0.4, 0.4, 0.6),  # DUSK
	Color(0.1, 0.1, 0.2),  # NIGHT
]

var day_colors := {}
var inventory_tint: CanvasModulate
var the_core: TheCore
var player: Player


@export var tree_respawn_time: float = 180.0
@export var stone_respawn_time: float = 600.0

@export var build_tooltip: BuildTooltip
@export var inventory_darken: Color

@export_group("Enemies")
@export var zombie_scene: PackedScene

#@export_group("Building")
#@export var torch_scene: PackedScene

signal world_loaded()

func _ready() -> void:
	GameManager.is_game_loaded = false
	get_tree().paused = true
	day_colors = {
		6:  lighting_colors[TimeOfDay.DAWN],
		7:  lighting_colors[TimeOfDay.SUNRISE],
		8:  lighting_colors[TimeOfDay.DAY],
		18: lighting_colors[TimeOfDay.SUNSET],
		19: lighting_colors[TimeOfDay.DUSK],
		20: lighting_colors[TimeOfDay.NIGHT],
	}
	##GameManager
	GameManager.hour_changed.connect(_on_hour_changed)
	GameManager.set_day(1)
	GameManager.set_hour(8)
	
	##Invis all
	cheat_mode_label.visible = false
	menu.visible = false
	build_tooltip.visible = false
	
	
	##Preload
	player = preload("res://Scenes/Player.tscn").instantiate()
	the_core = preload("uid://s0p5vesfuqst").instantiate()
	
	##Connect signals
	await  GameManager.wait_for_node(map)
	map.region_generated.connect(_on_region_generated)
	player.health_update.connect(hud.ui.health_changed)
	
	##Generate or load the world.
	await GameManager.wait_for_node(map)
	
	if GameManager.is_loading_save:
		print("Loading the world from save " + GameManager.current_save_name)
		SaveManager.load_save(GameManager.current_save_name)
	else:
		print("Generating the world without load.")
		generate(GameManager.current_world_seed)
	
	
	canvas_modulate.color = day_colors[8]
	label.text = "Hour: " + str(GameManager.current_hour) + ":00"
	## Set "player" variable in the hud.gd
	await GameManager.wait_for_node(hud)
	await GameManager.wait_for_node(player)
	await GameManager.wait_for_node(player.weapon)
	
	
	##Connect later signals
	hud.hotbar.slot_item_changed.connect(
		func(index: int, slot_data: SlotData) -> void:
			player.set_hotbar_item(index, slot_data)
	)
	hud.hotbar.slot_selected.connect(
		func(index: int) -> void:
			player.on_hotbar_selected_by_ui(index)
	)
	hud.hotbar.slot_selected.connect(player._on_hotbar_slot_selected)
	hud.inv_toggled.connect(player._on_inv_toggled)
	
	##Set hud vars
	hud.player = player
	hud.weapon = player.weapon
	hud.tooltip.inventory = hud.inventory
	hud.inventory.player = player
	hud.inventory.tooltip = hud.tooltip
	hud.inventory.hud = hud
	hud.inventory.hotbar = hud.hotbar
	hud.inventory.basic_crafting = hud.basic_crafting
	hud.basic_crafting.inventory = hud.inventory
	hud.hotbar.sync_from_player()
	##Check if everything is ok.
	hud.set_vars_debug()
	##Set player vars
	player.hud = hud
	player.inventory_ui = hud.get_node("InventoryUI")
	player.weapon.player = player
	player.weapon.hud = hud
	hud.weapon = player.weapon
	##Check if everything is ok.
	player.set_vars_debug()
	
	map.player = player
	inventory_tint = hud.canvas_modulate
	
	
	get_tree().paused = false
	GameManager.is_game_loaded = true
	print("After generating the game, the seed is: " + str(GameManager.current_world_seed))
	world_loaded.emit()

func generate(seed_f_g: int = 12) -> void:
	print("Generating the world...")
	map.generate_region(Vector2i(0, 0), seed_f_g)
	map.generate_region(Vector2i(1, 1), seed_f_g)
	map.generate_region(Vector2i(1, 0), seed_f_g)
	map.generate_region(Vector2i(0, 1), seed_f_g)
	map.generate_region(Vector2i(-1, 0), seed_f_g)
	map.generate_region(Vector2i(-1, 1), seed_f_g)
	map.generate_region(Vector2i(1, -1), seed_f_g)
	map.generate_region(Vector2i(0, -1), seed_f_g)
	map.generate_region(Vector2i(-1, -1), seed_f_g)
	spawn_player(Vector2(0, 0))
	spawn_the_core(player.global_position + Vector2(0, -250))
	if !OS.is_debug_build():
		drop_item(ItemRegistry.items.get("wooden_axe"), Vector2(0, -150))

func _on_mining_resource_destroyed(type: String, pos: Vector2) -> void:
	if type == "tree":
		var tree_respawn_timer := Timer.new()
		#tree_respawn_timer.timeout.connect(_on_tree_respawn_timer_timeout)
		respawn_timers.add_child(tree_respawn_timer)
		tree_respawn_timer.start(tree_respawn_time)
		await tree_respawn_timer.timeout
		spawn_tree(pos)
	if type == "stone":
		var stone_respawn_timer := Timer.new()
		respawn_timers.add_child(stone_respawn_timer)
		stone_respawn_timer.start(stone_respawn_time)
		await stone_respawn_timer.timeout
		spawn_stone(pos)

func _on_tree_respawn_timer_timeout() -> void:
	pass

func _on_hour_changed(hour: int) -> void:
	label.text = "Hour: " + str(hour) + ":00"
	_update_lightning(hour)
	
	if hour == 12:
		for spawner: Spawner in spawners.get_children():
			spawner.spawn_enemy()
	
	if hour >= 18 or hour <= 6:
		hud.tint_hud(inventory_darken, 25)
	else:
		hud.tint_hud(Color(1, 1, 1), 25)

func game_over() -> void:
	var game_over_scene := preload("res://Scenes/GameOver.tscn").instantiate()
	add_child(game_over_scene)
	AudioManager.play_game_over()
	get_tree().paused = true

func _update_lightning(hour: int) -> void:
	if !day_colors.has(hour): return
	var target_color: Color = day_colors[hour]
	var tween := create_tween()
	tween.tween_property(canvas_modulate, "color", target_color, 25)
	
	var target_vignette: float
	if hour >= 20 or hour < 6:
		target_vignette = 0.8
	elif hour == 6 or hour == 19:
		target_vignette = 0.9
	else:
		target_vignette = 0.95
	map.set_vignette_strength(target_vignette, 25)

func spawn_enemy(scene: PackedScene, pos: Vector2) -> void:
	var enemy := scene.instantiate()
	enemy.global_position = pos
	Ysort.add_child(enemy)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		if menu.visible:
			hide_menu()
		else:
			show_menu()
	
	if event.is_action_pressed("DEBUG spawn_enemy"):
		if !OS.is_debug_build(): return
		for i in range(20):
			var rand_pos: Vector2 = Vector2(randi_range(-200, 200), randi_range(-200, 200))
			spawn_enemy(zombie_scene, get_global_mouse_position() + rand_pos)

func _on_region_generated(new_trees: Array, new_spawners: Array, new_stones: Array) -> void:
	for pos: Vector2 in new_trees:
		spawn_tree(pos)
	for pos: Vector2 in new_spawners:
		add_spawner(pos)
	for pos: Vector2 in new_stones:
		spawn_stone(pos)

func drop_item(item: ItemData, pos: Vector2, random_range: int = 0) -> void:
	var dropped_item := preload("res://Scenes/dropped_item.tscn").instantiate()
	dropped_item.item_data = item
	dropped_item.global_position = pos + Vector2(randi_range(random_range, -random_range), randi_range(random_range, -random_range))
	dropped_item.picked_up.connect(player.pick_item)
	Ysort.call_deferred("add_child", dropped_item)

func spawn_tree(pos: Vector2) -> void:
	var tree := preload("res://Scenes/the_tree.tscn").instantiate()
	tree.resource_destroyed.connect(_on_mining_resource_destroyed)
	tree.global_position = pos
	Ysort.add_child(tree)

func spawn_stone(pos: Vector2) -> void:
	var stone := preload("res://Scenes/stone.tscn").instantiate()
	stone.resource_destroyed.connect(_on_mining_resource_destroyed)
	stone.global_position = pos
	Ysort.add_child(stone)

func spawn_building(pos: Vector2, build_scene: PackedScene) -> void:
	var building: BuildScene = build_scene.instantiate()
	building.preview_only = false
	building.global_position = pos
	Ysort.add_child(building)

func add_spawner(pos: Vector2) -> void:
	var spawner := preload("res://Scenes/enemy_spawner.tscn").instantiate()
	spawner.global_position = pos
	spawner.main = self
	spawners.add_child(spawner)

func spawn_player(pos: Vector2) -> void:
	player.global_position = pos
	Ysort.add_child(player)

func spawn_the_core(pos: Vector2) -> void:
	the_core.global_position = pos
	the_core.main = self
	Ysort.add_child(the_core)

func show_build_item_tooltip(target: Node2D) -> void:
	build_tooltip.tooltip_target = target
	build_tooltip.visible = true
	print("imagine showing the tooltip.")

func give_player_item(item_data: ItemData, amount: int = 1) -> void:
	if !hud: printerr("Trying to give item to player, but hud is null"); return
	hud.give_item(item_data, amount)

func show_menu() -> void:
	menu.visible = true
	get_tree().paused = true

func hide_menu() -> void:
	menu.visible = false
	get_tree().paused = false
