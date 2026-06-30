extends Node
## Handle global sound; autoload

var machine_gun_player: AudioStreamPlayer

var music_tracks: Array[AudioStream] = [
	preload("res://Music/BackgroundMusic1.ogg"),
	preload("res://Music/BackgroundMusic2.ogg"),
	preload("res://Music/BackgroundMusic3.ogg"),
	preload("res://Music/BackgroundMusic4.ogg")
]
var current_music_player: AudioStreamPlayer
var music_playing: bool = false
var rng := RandomNumberGenerator.new()
var last_track: AudioStream
var sounds: Dictionary = {
	"button_click": preload("res://sounds/ButtonClick.mp3"),
	"game_over": preload("res://sounds/GameOverSound.mp3"),
	"small_gun_shot": preload("res://SFX/SmallGunShot.wav"),
	"shotgun_reload": preload("res://SFX/ShotgunReload.wav"),
	"machinegun_shot": preload("res://SFX/MachineGunShot.wav"),
	"bullet_landing": preload("res://SFX/BulletLanding.wav"),
	"machinegun_loop": preload("res://SFX/MachineGunLoop.wav"),
	"machinegun_stop": preload("res://SFX/MachineGunStop.wav"),
	"typing_sound": preload("res://sounds/TypingSound.mp3"),
	"falling_tree": preload("res://SFX/FallingTree.wav"),
	"leaves_rustling": preload("res://SFX/LeavesRustling.wav"),
	"building_built": preload("res://SFX/BuildingBuilt.wav"),
	"building_picked_up": preload("res://SFX/BuildingPickedUp.wav")
}
var last_played := {}
var min_interval := {
	"machinegun_shot": 0.035,
	"bullet_landing": 0.035,
	"leaves_rustling": 0.01,
	"falling_tree": 0.01
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _play_sound(stream: AudioStream, added_volume: float = 0, bus: String = "Master") -> void:
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.bus = bus
	player.volume_db = added_volume
	player.stream = stream
	player.finished.connect(player.queue_free)
	player.play()

func _play_sound_2d(stream: AudioStream, pos: Vector2, added_volume: float = 0, bus: String = "Master") -> void:
	var player := AudioStreamPlayer2D.new()
	get_tree().current_scene.add_child(player)
	player.bus = bus
	player.attenuation = 5
	player.volume_db = added_volume
	player.stream = stream
	player.global_position = pos
	player.finished.connect(player.queue_free)
	player.play()

func play(sound: String, added_volume: float = 0) -> void:
	if sounds.has(sound):
		_play_sound(sounds[sound], added_volume, "Master")

func play_sfx(sound: String, added_volume: float = 0) -> void:
	if !sound in sounds:
		return
	var now := Time.get_ticks_msec() / 1000.0
	
	if min_interval.has(sound):
		var last: Variant = last_played.get(sound, 0.0)
		if now - last < min_interval[sound]:
			return
	
	last_played[sound] = now
	_play_sound(sounds[sound], added_volume, "SFX")

func play_sfx_2d(sound: String, pos: Vector2, added_volume: float = 0) -> void:
	if !sound in sounds:
		return
	var now := Time.get_ticks_msec() / 1000.0
	
	if min_interval.has(sound):
		var last: Variant = last_played.get(sound, 0.0)
		if now - last < min_interval[sound]:
			return
	
	last_played[sound] = now
	_play_sound_2d(sounds[sound], pos, added_volume, "SFX")

##------------------------------------- BG MUSIC ------------------------------------------------------

func start_background_music() -> void:
	if music_playing or music_tracks.is_empty():
		return
	music_playing = true
	rng.randomize()
	_play_next_track()

func _play_next_track() -> void:
	if !music_playing:
		return
	
	var track: AudioStream
	var attempts := 0
	const MAX_ATTEMPTS := 10
	
	while attempts < MAX_ATTEMPTS:
		track = music_tracks[rng.randi_range(0, music_tracks.size() - 1,)]
		if music_tracks.size() == 1 or track != last_track:
			break	
		attempts += 1
	
	if track == null:
		track = music_tracks[1]
	
	last_track = track
	
	if current_music_player:
		current_music_player.queue_free()
	
	current_music_player = AudioStreamPlayer.new()
	add_child(current_music_player)
	current_music_player.bus = "Music"
	current_music_player.stream = track
	current_music_player.volume_db = -10.0
	current_music_player.finished.connect(_on_music_finished)
	current_music_player.play()

func _on_music_finished() -> void:
	if !music_playing:
		return
	
	var break_time := rng.randf_range(3.0, 15.0)
	await get_tree().create_timer(break_time).timeout
	_play_next_track()

func stop_background_music() -> void:
	music_playing = false
	if current_music_player:
		current_music_player.stop()
		current_music_player.queue_free()

##------------------------------------------------ SETTINGS ---------------------------------

func set_music_volume_db(db: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)

func get_music_volume_db() -> float:
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))

func set_sfx_volume_db(db: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)

func get_sfx_volume_db() -> float:
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))

func set_master_volume_db(db: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)

func get_master_volume_db() -> float:
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
