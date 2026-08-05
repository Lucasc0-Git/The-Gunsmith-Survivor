extends Control
class_name Encyclopedy

@onready var open_button: Button = $Button
@onready var hud: Hud = get_parent()
@onready var not_implemented_dialog: AcceptDialog = $AcceptDialog

@export var visible_button_position: Vector2
@export var hidden_button_position: Vector2
@export var trigger_dist: float = 200.0

var _open_tween: Tween
var is_open_button_toggled: bool = false

func _ready() -> void:
	open_button.mouse_entered.connect(
		func () -> void: hud.toggle_hovering(true)
	)
	open_button.mouse_exited.connect(
		func () -> void: hud.toggle_hovering(false)
	)
	not_implemented_dialog.confirmed.connect(
		func () -> void: open_button.button_pressed = false
	)
	not_implemented_dialog.canceled.connect(
		func () -> void: open_button.button_pressed = false
	)
	is_open_button_toggled = true
	open_button.global_position = visible_button_position
	await get_tree().create_timer(3).timeout
	if not open_button.button_pressed:
		hide_open_button()
		is_open_button_toggled = false

func show_open_button() -> void:
	if open_button.global_position == visible_button_position:
		return
	if _open_tween: _open_tween.kill()
	_open_tween = create_tween()
	_open_tween.set_trans(Tween.TRANS_EXPO)
	_open_tween.set_ease(Tween.EASE_OUT)
	_open_tween.tween_property(open_button, "position", visible_button_position, 0.7)

func hide_open_button() -> void:
	if open_button.global_position == hidden_button_position:
		return
	if _open_tween: _open_tween.kill()
	_open_tween = create_tween()
	_open_tween.set_trans(Tween.TRANS_EXPO)
	_open_tween.set_ease(Tween.EASE_OUT)
	_open_tween.tween_property(open_button, "position", hidden_button_position, 0.7)

func _process(_delta: float) -> void:
	
	if is_open_button_toggled: return
	var mouse_pos := get_global_mouse_position()
	var dist: float = mouse_pos.distance_to(open_button.global_position)
	if dist < trigger_dist:
		show_open_button()
	else:
		hide_open_button()

func _on_button_toggled(toggled_on: bool) -> void:
	is_open_button_toggled = toggled_on
	if toggled_on:
		not_implemented_dialog.popup_centered()
	else:
		not_implemented_dialog.hide()
