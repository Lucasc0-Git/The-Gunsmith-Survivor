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

@export var inventory_darken: Color

@export_group("Enemies")
@export var zombie_scene: PackedScene

func _ready() -> void:
	day_colors = {
		6:  lighting_colors[TimeOfDay.DAWN],
		7:  lighting_colors[TimeOfDay.SUNRISE],
		8:  lighting_colors[TimeOfDay.DAY],
		18: lighting_colors[TimeOfDay.SUNSET],
		19: lighting_colors[TimeOfDay.DUSK],
		20: lighting_colors[TimeOfDay.NIGHT],
	}
	canvas_modulate.color = day_colors[8]
	cheat_mode_label.visible = false
	spawn_player(Vector2(0, 0))
	spawn_the_core(player.global_position + Vector2(0, -250))
	label.text = "Hour: " + str(GameManager.current_hour) + ":00"
	## Set "player" variable in the hud.gd
	GameManager.hour_changed.connect(_on_hour_changed)
	menu.visible = false
	hud.set_player(player)
	player.set_vars(hud)
	player.health_update.connect(hud.ui.health_changed)
	map.player = player
	map.region_generated.connect(_on_region_generated)
	map.generate_region(Vector2i(0, 0))
	map.generate_region(Vector2i(1, 1))
	GameManager.set_day(1)
	GameManager.set_hour(8)
	inventory_tint = hud.canvas_modulate

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
		for i in range(20):
			var rand_pos: Vector2 = Vector2(randi_range(-200, 200), randi_range(-200, 200))
			spawn_enemy(zombie_scene, get_global_mouse_position() + rand_pos)

func _on_region_generated(new_trees: Array, new_spawners: Array) -> void:
	for pos: Vector2 in new_trees:
		spawn_tree(pos)
	for pos: Vector2 in new_spawners:
		add_spawner(pos)

func drop_item(item: ItemData, pos: Vector2) -> void:
	var dropped_item := preload("res://Scenes/dropped_item.tscn").instantiate()
	dropped_item.item_data = item
	dropped_item.global_position = pos
	dropped_item.picked_up.connect(player.pick_item)
	Ysort.call_deferred("add_child", dropped_item)

func spawn_tree(pos: Vector2) -> void:
	var tree := preload("res://Scenes/the_tree.tscn").instantiate()
	tree.global_position = pos
	Ysort.add_child(tree)

func add_spawner(pos: Vector2) -> void:
	var spawner := preload("res://Scenes/enemy_spawner.tscn").instantiate()
	spawner.global_position = pos
	spawner.main = self
	spawners.add_child(spawner)

func spawn_player(pos: Vector2) -> void:
	player = preload("res://Scenes/Player.tscn").instantiate()
	player.global_position = pos
	Ysort.add_child(player)

func spawn_the_core(pos: Vector2) -> void:
	the_core = preload("uid://s0p5vesfuqst").instantiate()
	the_core.global_position = pos
	the_core.main = self
	Ysort.add_child(the_core)

func show_menu() -> void:
	menu.visible = true
	get_tree().paused = true

func hide_menu() -> void:
	menu.visible = false
	get_tree().paused = false
