extends CanvasLayer
class_name GameOver

@onready var color_rect: ColorRect = $ColorRect


func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	AudioManager.play_button_click()
	get_tree().change_scene_to_file("res://Scenes/StartScene.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_play_button_pressed() -> void:
	get_parent().cheat_mode_label.visible = true
	get_tree().paused = false
	get_parent().the_core.health = get_parent().the_core.max_health
	queue_free()
