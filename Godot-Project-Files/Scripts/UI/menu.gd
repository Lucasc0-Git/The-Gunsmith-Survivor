extends CanvasLayer

@onready var main: Main = get_parent()
@onready var pause_menu: Control = $PauseMenu
@onready var opt_menu: Control = $OptMenu
@onready var save_question: Control = $SaveQuestion
@onready var score_label: Label = $PauseMenu/ScoreLabel
@onready var load_list: Control = $LoadList
@onready var save_list: Control = $SaveList

var score_label_value: int = 0

func _ready() -> void:
	score_label.text = str("Score: ", score_label_value)
	hide_opt()
	hide_save_question()
	hide_load_list()
	hide_save_list()

func _on_resume_button_pressed() -> void:
	AudioManager.play_button_click()
	main.hide_menu()

func _on_save_game_button_pressed() -> void:
	AudioManager.play_button_click()
	show_save_list()

func _on_load_game_button_pressed() -> void:
	AudioManager.play_button_click()
	show_load_list()

func _on_menu_button_pressed() -> void:
	AudioManager.play_button_click()
	if get_tree().paused: get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/StartScene.tscn")

func _on_options_button_pressed() -> void:
	AudioManager.play_button_click()
	show_opt()

func _on_quit_button_pressed() -> void:
	AudioManager.play_button_click()
	show_save_question()
	#get_tree().quit()

func show_opt() -> void:
	pause_menu.visible = false
	opt_menu.visible = true

func hide_opt() -> void:
	pause_menu.visible = true
	opt_menu.visible = false

func show_save_question() -> void:
	pause_menu.visible = false
	save_question.visible = true

func hide_save_question() -> void:
	pause_menu.visible = true
	save_question.visible = false

func show_load_list() -> void:
	pause_menu.visible = false
	load_list.visible = true

func hide_load_list() -> void:
	pause_menu.visible = true
	load_list.visible = false

func show_save_list() -> void:
	pause_menu.visible = false
	save_list.visible = true

func hide_save_list() -> void:
	pause_menu.visible = true
	save_list.visible = false

func hide_everything() -> void:
	pause_menu.visible = true
	save_list.visible = false
	load_list.visible = false
	save_question.visible = false
	opt_menu.visible = false

func _process(_delta: float) -> void:
	if pause_menu.visible:
		if score_label_value != GameManager.score:
			score_label_value = GameManager.score
			score_label.text = str("Score: ", score_label_value)


func _on_load_list_back_button_pressed() -> void: ## Back button for load list
	hide_load_list()

func _on_save_list_back_button_pressed() -> void: ## Back button for save list
	hide_save_list()
