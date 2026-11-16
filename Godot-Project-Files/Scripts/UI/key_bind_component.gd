extends PanelContainer
class_name KeyBindComponent

@export var binding_action: String = ""##The plain string that serves as the action's ID.
@export var action_name: String = ""##The "pretty" version of the action's name that can be seen by the player.
@export var options_scene: OptionsScene

@onready var binding_button: Button = $HBoxContainer/Button
@onready var action_label: Label = $HBoxContainer/Label

signal binding_started()
signal binding_ended()

var binding: bool = false

func _ready() -> void:
	if binding_action == "" or action_name == "":
		return
	action_label.text = action_name
	
	binding_started.connect(_on_binding_started)
	binding_ended.connect(_on_binding_ended)
	
	_update_button_text()

func _on_binding_started() -> void:
	binding = true
	binding_button.button_pressed = true
	binding_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_button_text()

func _on_binding_ended() -> void:
	binding = false
	binding_button.button_pressed = false
	binding_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_update_button_text()

func _input(event: InputEvent) -> void:
	if not binding: return
	
	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
		binding_ended.emit()
		get_viewport().set_input_as_handled()
		return
	
	if event is InputEventKey:
		if not event.pressed or event.echo:
			return
		
		_apply_new_event(event)
		return
	
	if event is InputEventMouseButton:
		if not event.pressed:
			return
		_apply_new_event(event)
		return

func _apply_new_event(event: InputEvent) -> void:
	get_viewport().set_input_as_handled()
	
	var clean := event.duplicate()
	if clean is InputEventMouseButton:
		clean.position = Vector2.ZERO
		clean.global_position = Vector2.ZERO
		clean.double_click = false
	
	InputMap.action_erase_events(binding_action)
	InputMap.action_add_event(binding_action, clean)
	
	Settings.save()
	binding_ended.emit()

func _on_button_pressed() -> void:
	binding_started.emit()

func _update_button_text() -> void:
	if binding:
		binding_button.text = "Binding..."
		return
	
	var events := InputMap.action_get_events(binding_action)
	if events.is_empty():
		binding_button.text = "None"
		return
	binding_button.text = get_event_display_name(events[0])

func get_event_display_name(event: InputEvent) -> String:
	if event is InputEventKey:
		var code: Variant = event.physical_keycode if event.physical_keycode != KEY_NONE else event.keycode
		return OS.get_keycode_string(code)
	
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT: return "Left Mouse"
			MOUSE_BUTTON_RIGHT: return "Right Mouse"
			MOUSE_BUTTON_MIDDLE: return "Middle Mouse"
			MOUSE_BUTTON_WHEEL_UP: return "Wheel Up"
			MOUSE_BUTTON_WHEEL_DOWN: return "Wheel Down"
			MOUSE_BUTTON_XBUTTON1: return "Mouse 4"
			MOUSE_BUTTON_XBUTTON2: return "Mouse 5"
			_: return "Mouse %d" % event.button_index
	
	return event.as_text().get_slice(" (", 0).strip_edges()

func reset_action_to_default() -> void:
	var setting: Dictionary = ProjectSettings.get_setting("input/" + binding_action)
	if setting == null: return
	
	InputMap.action_erase_events(binding_action)
	
	var default_events: Array = setting.get("events", [])
	for event: InputEvent in default_events:
		InputMap.action_add_event(binding_action, event)
	_update_button_text()

func _on_button_gui_input(event: InputEvent) -> void:
	if binding: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		get_viewport().set_input_as_handled()
		reset_action_to_default()
