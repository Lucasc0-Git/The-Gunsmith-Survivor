extends Node
## Handle global sound; autoload

@onready var button_click : AudioStream = preload("res://sounds/soundreality-pop-click-312649.mp3")
@onready var audioplayer := AudioStreamPlayer.new()

func _ready() -> void:
	add_child(audioplayer)

func play_button_click() -> void:
	audioplayer.stream = button_click
	audioplayer.play()
