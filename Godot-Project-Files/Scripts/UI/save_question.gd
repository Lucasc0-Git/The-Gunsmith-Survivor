extends Control

@onready var yes_button := $HBoxContainer/YesButton
@onready var no_button := $HBoxContainer/NoButton
@onready var menu := get_parent()


func _on_yes_button_pressed() -> void:
	if visible:
		SaveManager.save_game(GameManager.current_save_name)
		Settings.save()
		get_tree().quit()


func _on_no_button_pressed() -> void:
	if visible:
		Settings.save()
		get_tree().quit()


func _on_back_button_pressed() -> void:
	if visible:
		AudioManager.play("button_click")
		menu.hide_save_question()
