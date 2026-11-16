extends Node

var fullscreen: bool = false
var vsync: bool = false
var sounds: bool = true
var novice_mode: bool = true
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var master_volume: float = 1.0

var tracked_actions: Array[String] = [
	"move_up",
	"move_down",
	"move_left",
	"move_right",
	"shoot",
	"toggle_inventory",
	"prev_weapon",
	"next_weapon",
	"slot_1_hotbar",
	"slot_2_hotbar",
	"slot_3_hotbar",
	"slot_4_hotbar",
	"slot_5_hotbar",
	"Dodge",
	"quick_save",
	"fullscreen_toggle",
	
]

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
	
	for action in tracked_actions:
		var events := InputMap.action_get_events(action)
		if events.is_empty():
			continue
		var event: InputEvent = events[0]
		
		if event is InputEventKey:
			cfg.set_value("binding", action, {
				"type": "key",
				"keycode": event.physical_keycode if event.physical_keycode != KEY_NONE else event.keycode
			})
		elif event is InputEventMouseButton:
			cfg.set_value("binding", action, {
				"type": "mouse",
				"button": event.button_index
			})
	
	var err := cfg.save(CONFIG_PATH)
	if err != OK:
		push_warning("Failed to save settings! Error code: %d" % err)

func load_cfg() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG_PATH) != OK:
		return
	
	##Video
	fullscreen = cfg.get_value("video", "fullscreen", false)
	vsync = cfg.get_value("video", "vsync", false)
	##Audio
	sounds = cfg.get_value("sounds", "global_sounds", true)
	master_volume = cfg.get_value("sounds", "master_volume", 1.0)
	music_volume = cfg.get_value("sounds", "music_volume", 1.0)
	sfx_volume = cfg.get_value("sounds", "sfx_volume", 1.0)
	##Global
	novice_mode = cfg.get_value("global", "novice_mode", true)
	##Binding
	for action in tracked_actions:
		if not cfg.has_section_key("binding", action):
			continue
		
		var data: Variant = cfg.get_value("binding", action)
		
		if data is Dictionary:
			InputMap.action_erase_events(action)
			match data.get("type", ""):
				"key":
					var e := InputEventKey.new()
					e.physical_keycode = data.get("keycode", KEY_NONE)
					
					InputMap.action_add_event(action, e)
				"mouse":
					var e := InputEventMouseButton.new()
					e.button_index = data.get("button", MOUSE_BUTTON_LEFT)
					
					InputMap.action_add_event(action, e)

func is_action_modified(action_name: String) -> bool:
	var default_setting: Variant = ProjectSettings.get_setting("input/" + action_name)
	if default_setting == null:
		return false
	
	var default_events: Array = default_setting.get("events", [])
	var current_events: Array = InputMap.action_get_events(action_name)
	
	if default_events.size() != current_events.size():
		return true
		
	for i in range(current_events.size()):
		if not current_events[i].is_match(default_events[i]):
			return true
			
	return false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen_toggle"):
		Settings.apply_fullscreen(!Settings.fullscreen)
