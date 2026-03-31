extends Control

@onready var new_game: Button = $VBoxContainer/NewGameButton
@onready var options: Button = $VBoxContainer/OptionsButton
@onready var StartScene : PackedScene = preload("res://Scenes/StartScene.tscn")
@export var MainScene : PackedScene
@export var OptScene : PackedScene

var world_seed := randi()

func _ready() -> void:
	GameManager.current_world_seed = world_seed

func _on_new_game_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_packed(MainScene)


func _on_options_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_packed(OptScene)


func _on_quit_button_pressed() -> void:
	Settings.save()
	get_tree().quit()


func _on_saves_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_file("res://Scenes/SavesScene.tscn")
