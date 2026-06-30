extends Node

var fullscreen: bool = false
var vsync: bool = false
var sounds: bool = true
var novice_mode: bool = true
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var master_volume: float = 1.0

const CONFIG_PATH := "user://settings.cfg"

signal fullscreen_changed(enabled: bool)
signal vsync_changed(enabled: bool)
signal sounds_changed(enabled: bool)
signal novice_mode_changed(enabled: bool)

func _ready() -> void:
	load_cfg()
	apply_settings()
	AudioManager.set_master_volume_db(linear_to_db(master_volume))
	AudioManager.set_music_volume_db(linear_to_db(music_volume))
	AudioManager.set_sfx_volume_db(linear_to_db(sfx_volume))

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

func set_novice_mode(enabled: bool) -> void:
	novice_mode = enabled
	novice_mode_changed.emit(enabled)
	save()

func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("video", "fullscreen", fullscreen)
	cfg.set_value("video", "vsync", vsync)
	cfg.set_value("sounds", "global_sounds", sounds)
	cfg.set_value("sounds", "master_volume", master_volume)
	cfg.set_value("sounds", "music_volume", music_volume)
	cfg.set_value("sounds", "sfx_volume", sfx_volume)
	cfg.set_value("global", "novice_mode", novice_mode)
	var err := cfg.save(CONFIG_PATH)
	if err != OK:
		push_warning("Failed to save settings! Error code: %d" % err)

func load_cfg() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG_PATH) == OK:
		fullscreen = cfg.get_value("video", "fullscreen", false)
		vsync = cfg.get_value("video", "vsync", false)
		sounds = cfg.get_value("sounds", "global_sounds", true)
		novice_mode = cfg.get_value("global", "novice_mode", true)
		master_volume = cfg.get_value("sounds", "master_volume", 1.0)
		music_volume = cfg.get_value("sounds", "music_volume", 1.0)
		sfx_volume = cfg.get_value("sounds", "sfx_volume", 1.0)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen_toggle"):
		Settings.apply_fullscreen(!Settings.fullscreen)
