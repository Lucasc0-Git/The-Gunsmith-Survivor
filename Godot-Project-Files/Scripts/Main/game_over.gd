extends CanvasLayer
class_name GameOver

@onready var color_rect: ColorRect = $ColorRect
@onready var stats_label: RichTextLabel = $PanelContainer/VBoxContainer/StatsLabel

func _ready() -> void:
	var bb: String = ""
	
	bb += "[ul]"
	for stat: String in GameManager.more_stats:
		var display_name: String = stat.capitalize().replace("_", " ")
		var value: Variant = GameManager.more_stats[stat]
		bb += display_name + ": " + str(value) + "\n"
	bb += "[/ul]"
	bb += "\n\n\n\n\n"
	
	bb += "[center][font_size=24]Total Score: " + str(GameManager.score) + "[/font_size][/center]\n"
	
	stats_label.text = bb

func _on_menu_button_pressed() -> void:
	GameManager.cheat_mode_enabled = false
	get_tree().paused = false
	AudioManager.play("button_click")
	get_tree().change_scene_to_file("res://Scenes/StartScene.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_play_button_pressed() -> void:
	GameManager.cheat_mode_enabled = true
	AudioManager.play("button_click")
	get_tree().paused = false
	get_parent().the_core.health = get_parent().the_core.max_health
	queue_free()
