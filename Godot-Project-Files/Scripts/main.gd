extends Node2D
class_name Main

## The @onready var declaration
@onready var hud: CanvasLayer = $HUD
@onready var player: Player
@onready var map: Map = $Map
@onready var menu: CanvasLayer = $Menu
@onready var Ysort := $YSORT
@onready var label: Label = $CanvasLayer/Label
@onready var spawners: Node2D = $Spawners

@export_group("Enemies")
@export var zombie_scene: PackedScene

func _ready() -> void:
	GameManager.set_day(1)
	GameManager.set_hour(6)
	
	var spawn_pos := map.get_spawn_position()
	spawn_player(spawn_pos)
	spawn_enemy(zombie_scene, Vector2(50, 50))
	
	label.text = "Hour: " + str(GameManager.current_hour) + ":00"
	## Set "player" variable in the hud.gd
	GameManager.hour_changed.connect(_on_hour_changed)
	menu.visible = false
	hud.set_player(player)
	player.set_vars(hud)
	player.health_update.connect(hud.ui.health_changed)
	map.player = player
	map.world_generated.connect(_on_world_generated)
	map.generate_world()

func _on_hour_changed(hour: int) -> void:
	label.text = "Hour: " + str(hour) + ":00"
	
	if hour == 12:
		for spawner: Spawner in spawners.get_children():
			spawner.spawn_enemy()

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

func _on_world_generated() -> void:
	for pos: Vector2 in map.tree_positions:
		spawn_tree(pos)
	for pos: Vector2 in map.spawner_positions:
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

func show_menu() -> void:
	menu.visible = true
	get_tree().paused = true

func hide_menu() -> void:
	menu.visible = false
	get_tree().paused = false
