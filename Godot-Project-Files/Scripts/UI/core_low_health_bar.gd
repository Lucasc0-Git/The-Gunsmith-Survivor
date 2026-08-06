extends Control

@export var hidden_pos: Vector2
@export var visible_pos: Vector2
@export var health_bar: ProgressBar
@export var anim_player: AnimationPlayer

var shown: bool = false:
	get():
		return _shown
	set(value):
		_shown = value
		_on_shown_toggled(value)

var _shown: bool = false
var _show_tween: Tween

@onready var main: Main = GameManager.main

func _ready() -> void:
	while !GameManager.is_game_loaded:
		await get_tree().process_frame
	if !main: main = GameManager.main
	
	main.the_core.core_health_changed.connect(_on_core_health_changed)
	
	health_bar.max_value = main.the_core.max_health
	health_bar.value = main.the_core.max_health

func _on_core_health_changed(health: float) -> void: 
	health_bar.value = clamp(health, 0.0, main.the_core.max_health)
	if health <= main.the_core.max_health / 1.75:
		if !shown:
			show_health_bar()
	else:
		if shown:
			hide_health_bar()

func show_health_bar() -> void:
	if _show_tween: _show_tween.kill()
	shown = true
	if global_position == visible_pos: return
	_show_tween = create_tween()
	_show_tween.tween_property(self, "global_position", visible_pos, 1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

func hide_health_bar() -> void:
	if _show_tween: _show_tween.kill()
	shown = false
	if global_position == hidden_pos: return
	_show_tween = create_tween()
	_show_tween.tween_property(self, "global_position", hidden_pos, 1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

func _on_shown_toggled(toggled_on: bool) -> void:
	var percentage_of_health: float = main.the_core.health / main.the_core.max_health
	if percentage_of_health >= 0.5:
		percentage_of_health = 1.0
	var speed: float = (1 / percentage_of_health) * 0.8
	
	if toggled_on:
		if anim_player.is_playing(): return
		anim_player.play("pulse", -1, speed)
	else:
		if anim_player.is_playing(): anim_player.stop()
