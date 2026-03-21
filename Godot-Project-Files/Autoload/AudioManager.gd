extends Node
## Handle global sound; autoload

@onready var button_click: AudioStream = preload("res://sounds/soundreality-pop-click-312649.mp3")
@onready var game_over: AudioStream = preload("res://sounds/freesound_community-negative_beeps-6008.mp3")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _play_sound(stream: AudioStream) -> void:
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream
	player.play()
	await player.finished
	player.queue_free()

func play_button_click() -> void:
	_play_sound(button_click)

func play_game_over() -> void:
	_play_sound(game_over)
