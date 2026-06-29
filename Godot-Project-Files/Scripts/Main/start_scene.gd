extends Control

@onready var new_game: Button = $VBoxContainer/HBoxContainer/NewGameButton
@onready var difficulty_button: OptionButton = $VBoxContainer/HBoxContainer/DifficultyButton
@onready var options: Button = $VBoxContainer/OptionsButton
@onready var StartScene : PackedScene = preload("res://Scenes/StartScene.tscn")
@onready var tutorial_panel: Control = $Control
@export var MainScene : PackedScene
@export var OptScene : PackedScene


func _ready() -> void:
	GameManager.is_game_loaded = false
	for i in range(GameManager.Difficulty.size()):
		var diff_name: String = GameManager.Difficulty.keys()[i]
		var display_name: String = diff_name.capitalize().replace("_", " ")
		difficulty_button.add_item(display_name, i)
	tutorial_panel.visible = false

func _process(_delta: float) -> void:
	if GameManager.is_game_loaded:
		GameManager.is_game_loaded = false

func _on_new_game_button_pressed() -> void:
	AudioManager.play("button_click")
	#get_tree().change_scene_to_packed(MainScene)
	if Settings.novice_mode:
		tutorial_panel.visible = true
		Settings.set_novice_mode(false)
	else:
		GameManager.selected_difficulty = difficulty_button.get_selected_id() as GameManager.Difficulty
		GameManager.difficulty_multiplier = GameManager.get_multiplier_for_difficulty(GameManager.selected_difficulty)
		GameManager.start_new_world()

func _on_tutorial_button_pressed() -> void:
	AudioManager.play("button_click")
	tutorial_panel.visible = true
	Settings.set_novice_mode(false)

func _on_saves_button_pressed() -> void:
	AudioManager.play("button_click")
	get_tree().change_scene_to_file("res://Scenes/SavesScene.tscn")

func _on_options_button_pressed() -> void:
	AudioManager.play("button_click")
	get_tree().change_scene_to_packed(OptScene)

func _on_quit_button_pressed() -> void:
	Settings.save()
	get_tree().quit()

func _on_back_button_pressed() -> void:
	AudioManager.play("button_click")
	tutorial_panel.visible = false
