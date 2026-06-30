extends Control

@onready var fullscreen_checkbox := $PanelContainer/MarginContainer/VBoxContainer/Fullscreen
@onready var vsync_checkbox : CheckButton = $PanelContainer/MarginContainer/VBoxContainer/Vsync
@onready var global_sounds_cb: CheckButton = $PanelContainer/MarginContainer/VBoxContainer/GlobalSounds
@onready var master_sound_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/MasterBusContainer/MarginContainer/VBoxContainer/MasterSoundSlider
@onready var sfx_sound_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/SFXBusContainer/MarginContainer/VBoxContainer/SFXSoundSlider
@onready var music_sound_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/MusicBusContainer/MarginContainer/VBoxContainer/MusicSoundSlider

var _save_timer: Timer

func _ready() -> void:
	_save_timer = Timer.new()
	_save_timer.one_shot = true
	_save_timer.wait_time = 0.5
	add_child(_save_timer)
	_save_timer.timeout.connect(_on_save_timer_timeout)
	
	fullscreen_checkbox.set_pressed_no_signal(Settings.fullscreen)
	vsync_checkbox.set_pressed_no_signal(Settings.vsync)
	global_sounds_cb.set_pressed_no_signal(Settings.sounds)
	master_sound_slider.set_value_no_signal(Settings.master_volume)
	music_sound_slider.set_value_no_signal(Settings.music_volume)
	sfx_sound_slider.set_value_no_signal(Settings.sfx_volume)
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
	AudioManager.play("button_click")
	get_tree().change_scene_to_file("res://Scenes/StartScene.tscn")

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	AudioManager.play("button_click")
	Settings.apply_fullscreen(toggled_on)

func _on_vsync_toggled(toggled_on: bool) -> void:
	AudioManager.play("button_click")
	Settings.apply_vsync(toggled_on)

func _on_global_sounds_toggled(toggled_on: bool) -> void:
	AudioManager.play("button_click")
	Settings.apply_sounds(toggled_on)

func _on_master_sound_slider_value_changed(value: float) -> void:
	AudioManager.set_master_volume_db(linear_to_db(value))
	Settings.master_volume = value
	_save_timer.start()

func _on_sfx_sound_slider_value_changed(value: float) -> void:
	AudioManager.set_sfx_volume_db(linear_to_db(value))
	Settings.sfx_volume = value
	_save_timer.start()

func _on_music_sound_slider_value_changed(value: float) -> void:
	AudioManager.set_music_volume_db(linear_to_db(value))
	Settings.music_volume = value
	_save_timer.start()

func _on_save_timer_timeout() -> void:
	Settings.save()
