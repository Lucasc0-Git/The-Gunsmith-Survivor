extends Control

@onready var back_button := $VBoxContainer/BackButton







func _on_back_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_file("res://Scenes/StartScene.tscn")
