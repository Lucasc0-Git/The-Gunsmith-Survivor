extends Control

@onready var new_game: Button = $VBoxContainer/NewGameButton
@onready var options: Button = $VBoxContainer/OptionsButton
@onready var StartScene : PackedScene = preload("res://Scenes/StartScene.tscn")
@onready var tutorial_panel: Control = $Control
@export var MainScene : PackedScene
@export var OptScene : PackedScene


func _ready() -> void:
	GameManager.is_game_loaded = false
	
	tutorial_panel.visible = false

func _process(_delta: float) -> void:
	if GameManager.is_game_loaded:
		GameManager.is_game_loaded = false

func _on_new_game_button_pressed() -> void:
	AudioManager.play_button_click()
	#get_tree().change_scene_to_packed(MainScene)
	GameManager.start_new_world()

func _on_tutorial_button_pressed() -> void:
	AudioManager.play_button_click()
	tutorial_panel.visible = true

func _on_saves_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_file("res://Scenes/SavesScene.tscn")

func _on_options_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_packed(OptScene)

func _on_quit_button_pressed() -> void:
	Settings.save()
	get_tree().quit()

func _on_back_button_pressed() -> void:
	AudioManager.play_button_click()
	tutorial_panel.visible = false
