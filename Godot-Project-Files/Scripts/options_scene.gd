extends Control

@onready var fullscreen_checkbox := $PanelContainer/MarginContainer/VBoxContainer/Fullscreen
@onready var vsync_checkbox : CheckButton = $PanelContainer/MarginContainer/VBoxContainer/Vsync
@onready var global_sounds_cb: CheckButton = $PanelContainer/MarginContainer/VBoxContainer/GlobalSounds


func _ready() -> void:
	fullscreen_checkbox.set_pressed_no_signal(Settings.fullscreen)
	vsync_checkbox.set_pressed_no_signal(Settings.vsync)
	global_sounds_cb.set_pressed_no_signal(Settings.sounds)
	Settings.fullscreen_changed.connect(_on_fullscreen_changed)
	Settings.vsync_changed.connect(_on_vsync_changed)
	Settings.sounds_changed.connect(_on_sounds_changed)

func _on_fullscreen_changed(enabled: bool) -> void:
	fullscreen_checkbox.set_pressed_no_signal(enabled)
func _on_vsync_changed(enabled: bool) -> void:
	vsync_checkbox.set_pressed_no_signal(enabled)
func _on_sounds_changed(enabled:bool) -> void:
	global_sounds_cb.set_pressed_no_signal(enabled)

func _on_back_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_file("res://Scenes/StartScene.tscn")

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	AudioManager.play_button_click()
	print("Checkbox: Fullscreen was toggled to:", toggled_on)
	Settings.apply_fullscreen(toggled_on)

func _on_vsync_toggled(toggled_on: bool) -> void:
	AudioManager.play_button_click()
	print("Checkbox: Vsync was toggled to: ", toggled_on)
	Settings.apply_vsync(toggled_on)

func _on_global_sounds_toggled(toggled_on: bool) -> void:
	AudioManager.play_button_click()
	print("Checkbox: Global Sounds was toggled to: ", toggled_on)
	Settings.apply_sounds(toggled_on)
