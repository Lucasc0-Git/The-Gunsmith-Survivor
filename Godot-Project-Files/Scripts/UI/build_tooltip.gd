extends CanvasLayer
class_name BuildTooltip

var tooltip_target: Node2D = null
var main: Main = null
@onready var control: Control = $Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
		tooltip_target = null
		visible = false


func _on_pick_up_button_pressed() -> void:
	if !main: print("main is null"); return
	if tooltip_target is BuildScene:
		if !tooltip_target.get_item_data(): print(null); return
		print(tooltip_target.get_item_data())
		main.give_player_item(tooltip_target.get_item_data())
		if is_instance_valid(tooltip_target):
			tooltip_target.queue_free()
		tooltip_target = null
	else:
		print("tooltip target is not buildscene")

func _on_test_button_pressed() -> void:
	print("Testing...")

func _on_visibility_changed() -> void:
	pass
