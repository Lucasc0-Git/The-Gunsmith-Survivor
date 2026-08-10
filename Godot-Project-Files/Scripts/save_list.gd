extends Control

@onready var v_box_container: VBoxContainer = $VBoxContainer2
@onready var line_edit: LineEdit = $HBoxContainer/LineEdit
@onready var difficulty_button: OptionButton = $HBoxContainer/DifficultyButton
@onready var rename_popup: AcceptDialog = $RenameDialog
@onready var save_failed_notice: AcceptDialog = $SaveFailedNotice
@onready var overwrite_confirmation_dialog: ConfirmationDialog = $OverwriteConfirmationDialog

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
		var rename: Button = Button.new()
		rename.icon = preload("res://Textures/RenamePencil.png") as Texture2D
		rename.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rename.expand_icon = true
		rename.custom_minimum_size = Vector2(50, 0)
		rename.pressed.connect(
			func () -> void: AudioManager.play_sfx("button_click"); _on_rename_save(save.name)
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
		h_box.add_child(rename)
		h_box.add_child(delete)

func _process(_delta: float) -> void:
	if Time.get_ticks_msec() % (1000 * 5) == 0:
		populate_save_list()

func _on_new_save_button_pressed() -> void:
	AudioManager.play("button_click")
	var save_name: String = line_edit.text
	if save_name.is_empty():
		return
	var save_names: Array = []
	for save in SaveManager.get_all_saves():
		save_names.append(save.name)
	if save_name in save_names:
		if await _overwrite_popup():
			SaveManager.delete_save(save_name)
		else:
			line_edit.clear()
			return
	
	GameManager.is_game_loaded = false
	GameManager.selected_difficulty = difficulty_button.get_selected_id() as GameManager.Difficulty
	GameManager.more_stats.set("Difficulty", GameManager.selected_difficulty)
	GameManager.start_new_world(save_name)

func _on_line_edit_text_change_rejected(_rejected_substring: String) -> void:
	AudioManager.play("typing_sound")

func _on_rename_save(save_name: String) -> void:
	if !save_name: return
	rename_popup.popup_centered()
	rename_popup.add_cancel_button("Cancel")
	rename_popup.confirmed.connect(
		func () -> void:
			AudioManager.play_sfx("button_click")
			var rename_line_edit: LineEdit = $RenameDialog/LineEdit
			var new_name: String = rename_line_edit.text
			if !new_name or new_name.is_empty(): rename_line_edit.clear(); return
			var saves: Array = SaveManager.get_all_saves()
			var save_names: Array = []
			for save: Dictionary in saves:
				save_names.append(save.name)
			if new_name in save_names: 
				rename_line_edit.clear()
				if await _overwrite_popup(): SaveManager.delete_save(new_name)
				else: return
			if SaveManager.rename_save(save_name, new_name):
				rename_line_edit.clear(); return
			else:
				save_failed_notice.popup_centered()
	)

func _overwrite_popup() -> bool:
	overwrite_confirmation_dialog.popup_centered()
	
	var choice := await _wait_for_dialog_response(overwrite_confirmation_dialog)
	return choice

func _wait_for_dialog_response(dialog: AcceptDialog) -> bool:
	var state := [false, false] # [responded, is_confirmed]
	
	var on_confirmed := func() -> void:
		AudioManager.play_sfx("button_click")
		if not state[0]:
			state[0] = true
			state[1] = true
			
	var on_canceled := func() -> void:
		AudioManager.play_sfx("button_click")
		if not state[0]:
			state[0] = true
			state[1] = false
			
	dialog.confirmed.connect(on_confirmed, CONNECT_ONE_SHOT)
	dialog.canceled.connect(on_canceled, CONNECT_ONE_SHOT)
	dialog.close_requested.connect(on_canceled, CONNECT_ONE_SHOT) # covers window 'X' close
	
	while not state[0]:
		await Engine.get_main_loop().process_frame
		
	return state[1]
