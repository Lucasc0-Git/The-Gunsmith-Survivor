extends Node
## Handle global sound; autoload

var machine_gun_player: AudioStreamPlayer
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
	"leaves_rustling": preload("res://SFX/LeavesRustling.wav")
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

func play_music(sound: String, added_volume: float = 0) -> void:
	if sounds.has(sound):
		_play_sound(sounds[sound], added_volume, "Music")
