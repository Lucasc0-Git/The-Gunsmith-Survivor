extends Control

@onready var menu := get_parent()

func _on_back_button_pressed() -> void:
	AudioManager.play("button_click")
	menu.hide_opt()
