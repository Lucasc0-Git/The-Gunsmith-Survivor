extends Control

@onready var v_box_container: VBoxContainer = $VBoxContainer2
@onready var line_edit: LineEdit = $HBoxContainer/LineEdit
@onready var difficulty_button: OptionButton = $HBoxContainer/DifficultyButton

func _ready() -> void:
	SaveManager.save_list_changed.connect(populate_save_list)
	difficulty_button.clear()
	for i in range(GameManager.Difficulty.size()):
		var diff_name: String = GameManager.Difficulty.keys()[i]
		var display_name: String = diff_name.capitalize().replace("_", " ")
		difficulty_button.add_item(display_name, i)
	populate_save_list()

func populate_save_list() -> void:
	for child in v_box_container.get_children():
		child.queue_free()
	var saves := SaveManager.get_all_saves()
	saves.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["timestamp"] > b["timestamp"])
	
	for save in saves:
		
		var h_box: HBoxContainer = HBoxContainer.new()
		h_box.add_theme_constant_override("separation", 10)
		v_box_container.add_child(h_box)
		
		var btn: Button = Button.new()
		btn.text = "%s - %s" % [save.name, Time.get_date_string_from_unix_time(save.timestamp)]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(
			func() -> void: AudioManager.play("button_click") ;GameManager.load_world(save.name)
		)
		var delete: Button = Button.new()
		delete.icon = preload("res://Textures/TrashCan.png") as Texture2D
		delete.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		delete.expand_icon = true
		delete.custom_minimum_size = Vector2(50, 0)
		delete.pressed.connect(
			func() -> void: AudioManager.play("button_click"); SaveManager.delete_save(save.name)
		)
		h_box.add_child(btn)
		h_box.add_child(delete)

func _process(_delta: float) -> void:
	if Time.get_ticks_msec() % (1000 * 5) == 0:
		populate_save_list()

func _on_new_save_button_pressed() -> void:
	AudioManager.play("button_click")
	var save_name: String = line_edit.text
	if save_name.is_empty():
		return
	GameManager.is_game_loaded = false
	GameManager.selected_difficulty = difficulty_button.get_selected_id() as GameManager.Difficulty
	GameManager.more_stats.set("Difficulty", GameManager.selected_difficulty)
	GameManager.start_new_world(save_name)

func _on_line_edit_text_change_rejected(_rejected_substring: String) -> void:
	AudioManager.play("typing_sound")
