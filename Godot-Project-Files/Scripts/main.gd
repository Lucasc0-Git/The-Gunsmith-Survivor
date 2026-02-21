extends Node2D
class_name Main

## The @onready var declaration
@onready var hud: CanvasLayer = $HUD
@onready var player: Player = $Player
@onready var map: Node2D = $Map
@onready var menu: CanvasLayer = $Menu

func _ready() -> void:
	## Set "player" variable in the hud.gd
	menu.visible = false
	hud.set_player(player)
	player.set_vars(hud)
	player.health_update.connect(hud.ui.health_changed)
	map.player = player


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		if menu.visible:
			hide_menu()
		else:
			show_menu()

func show_menu() -> void:
	menu.visible = true
	get_tree().paused = true

func hide_menu() -> void:
	menu.visible = false
	get_tree().paused = false
