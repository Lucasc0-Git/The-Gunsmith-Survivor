extends Control

@onready var v_box_container: VBoxContainer = $VBoxContainer2
@onready var line_edit: LineEdit = $HBoxContainer/LineEdit
@onready var menu: CanvasLayer = get_parent()

func _ready() -> void:
	SaveManager.save_list_changed.connect(populate_save_list)
	visibility_changed.connect(func() -> void: populate_save_list())

func populate_save_list() -> void:
	for child in v_box_container.get_children():
		child.queue_free()
	
	for save_info in SaveManager.get_all_saves():
		
		var h_box: HBoxContainer = HBoxContainer.new()
		h_box.add_theme_constant_override("separation", 10)
		v_box_container.add_child(h_box)
		
		var btn: Button = Button.new()
		btn.text = "%s - %s" % [save_info.name, Time.get_date_string_from_unix_time(save_info.timestamp)]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(
			func() -> void: AudioManager.play_button_click() ; SaveManager.save_game(save_info.name); populate_save_list(); menu.hide_save_list()
		)
		var delete: Button = Button.new()
		delete.icon = preload("res://Textures/TrashCan.png") as Texture2D
		delete.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		delete.expand_icon = true
		delete.custom_minimum_size = Vector2(50, 0)
		delete.pressed.connect(
			func() -> void: AudioManager.play_button_click(); SaveManager.delete_save(save_info.name); populate_save_list()
		)
		h_box.add_child(btn)
		h_box.add_child(delete)

func _process(_delta: float) -> void:
	if !visible: return
	if Time.get_ticks_msec() % (1000 * 5) == 0:
		populate_save_list()

func _on_save_button_pressed() -> void:
	var save_name: String = line_edit.text
	if save_name.is_empty():
		return
	SaveManager.save_game(save_name)
	populate_save_list()
	menu.hide_save_list()
