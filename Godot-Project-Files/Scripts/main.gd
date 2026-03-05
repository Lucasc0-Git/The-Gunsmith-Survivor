extends Node2D
class_name Main

## The @onready var declaration
@onready var hud: CanvasLayer = $HUD
@onready var player: Player
@onready var map: Map = $Map
@onready var menu: CanvasLayer = $Menu
@onready var Ysort := $YSORT

func _ready() -> void:
	
	var spawn_pos := map.get_spawn_position()
	spawn_player(spawn_pos)
	
	## Set "player" variable in the hud.gd
	menu.visible = false
	hud.set_player(player)
	player.set_vars(hud)
	player.health_update.connect(hud.ui.health_changed)
	map.player = player
	map.world_generated.connect(_on_world_generated)
	map.generate_world()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		if menu.visible:
			hide_menu()
		else:
			show_menu()

func _on_world_generated() -> void:
	for pos: Vector2 in map.tree_positions:
		spawn_tree(pos)

func drop_item(item: ItemData, pos: Vector2) -> void:
	var dropped_item := preload("res://Scenes/dropped_item.tscn").instantiate()
	dropped_item.item_data = item
	dropped_item.global_position = pos
	print("connecting dropped item to player.pick_item")
	dropped_item.picked_up.connect(player.pick_item)
	Ysort.call_deferred("add_child", dropped_item)

func spawn_tree(pos: Vector2) -> void:
	var tree := preload("res://Scenes/the_tree.tscn").instantiate()
	tree.global_position = pos
	Ysort.add_child(tree)

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
