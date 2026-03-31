extends CanvasLayer

@onready var main: Main = get_parent()
@onready var pause_menu: Control = $PauseMenu
@onready var opt_menu: Control = $OptMenu
@onready var save_question: Control = $SaveQuestion

func _ready() -> void:
	hide_opt()
	hide_save_question()

func _on_resume_button_pressed() -> void:
	AudioManager.play_button_click()
	main.hide_menu()

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
