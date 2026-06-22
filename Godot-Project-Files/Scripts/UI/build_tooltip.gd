extends CanvasLayer
class_name BuildTooltip

var tooltip_target: Node2D = null
var main: Main = null
@onready var control: Control = $Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	while !GameManager.is_game_loaded:
		await get_tree().process_frame
	main = GameManager.main

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !main:
		if !GameManager.main:
			return
		else:
			main = GameManager.main
	if tooltip_target:
		var world_pos := tooltip_target.global_position
		var screen_pos := get_viewport().get_canvas_transform() * world_pos
		control.position = screen_pos + Vector2(10, -10)
	
	if not is_instance_valid(tooltip_target):
		hide_tooltip()

func _input(event: InputEvent) -> void:
	if !visible:
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var global_rect := control.get_global_rect()
		if not global_rect.has_point(control.get_global_mouse_position()):
			hide_tooltip()
			control.accept_event()
			return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E or event.keycode == KEY_ESCAPE:
			hide_tooltip()
			return

func _on_pick_up_button_pressed() -> void:
	if !main: print("BuildTooltip: Main is null!"); return
	if tooltip_target is BuildScene:
		if !tooltip_target.get_item_data(): print(null); return
		print(tooltip_target.get_item_data())
		main.give_player_item(tooltip_target.get_item_data())
		if is_instance_valid(tooltip_target):
			tooltip_target.queue_free()
		hide_tooltip()
	else:
		print("BuildTooltip target is not a BuildScene!")

func _on_test_button_pressed() -> void:
	print("Testing...")

func _on_visibility_changed() -> void:
	pass

func hide_tooltip() -> void:
	hide()
	tooltip_target = null

func show_tooltip(target: Node2D) -> void:
	show()
	tooltip_target = target
