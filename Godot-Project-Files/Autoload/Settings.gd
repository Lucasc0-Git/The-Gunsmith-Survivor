extends Node

var fullscreen: bool = false
var vsync: bool = false
var sounds: bool = true

const CONFIG_PATH := "user://settings.cfg"

signal fullscreen_changed(enabled: bool)
signal vsync_changed(enabled: bool)
signal sounds_changed(enabled: bool)

func _ready() -> void:
	load_cfg()
	apply_settings()

func apply_settings() -> void:
	apply_fullscreen(fullscreen)
	apply_vsync(vsync)
	apply_sounds(sounds)

func apply_fullscreen(enabled: bool) -> void:
	fullscreen = enabled
	
	if enabled:
		# True fullscreen → borderless false, clean fullscreen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	else:
		# Windowed → classic window, borderless off
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_move_to_foreground()
		DisplayServer.window_set_size(Vector2i(1280, 720))
	
	save()
	fullscreen_changed.emit(enabled)

func apply_vsync(enabled: bool) -> void:
	vsync = enabled
	
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if enabled
		else DisplayServer.VSYNC_DISABLED
	)
	save()
	vsync_changed.emit(enabled)

func apply_sounds(enabled: bool) -> void:
	sounds = enabled
	
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), !enabled)
	
	save()
	sounds_changed.emit(enabled)

func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("video", "fullscreen", fullscreen)
	cfg.set_value("video", "vsync", vsync)
	cfg.set_value("sounds", "global_sounds", sounds)
	var err := cfg.save(CONFIG_PATH)
	if err != OK:
		push_warning("Failed to save settings! Error code: %d" % err)

func load_cfg() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG_PATH) == OK:
		fullscreen = cfg.get_value("video", "fullscreen", false)
		vsync = cfg.get_value("video", "vsync", false)
		sounds = cfg.get_value("sounds", "global_sounds", true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen_toggle"):
		Settings.apply_fullscreen(!Settings.fullscreen)
