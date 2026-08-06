@tool
extends StaticBody2D
class_name BuildScene

@export var collision_shape: CollisionShape2D
@export var sprite: AnimatedSprite2D
@export var mouse_input: Area2D
@export var health_bar: ProgressBar
@export var anim_player: AnimationPlayer
@export var max_health: float = 100
@export var cursor_proximity_dist: int = 40

var health: float = 100:
	get():
		return _health
	set(value):
		value = clamp(value, 0, max_health)
		_health = value
		health_bar.value = value

var _health: float = 100
var _item_id: String = ""
var main: Main
var preview_only: bool = true

func _ready() -> void:
	if Engine.is_editor_hint():
		if ItemRegistry.items.is_empty():
			await ItemRegistry.items_loaded
		notify_property_list_changed()
	mouse_input.input_event.connect(_on_input_event)
	if !Engine.is_editor_hint():
		
		if GameManager.main != null:
			main = GameManager.main
		else:
			printerr("The 'main' variable in build_scene.gd is null!")
		
		health_bar.value = max_health
		health_bar.max_value = max_health
		health = max_health
		health_bar.visible = false

func _get_property_list() -> Array[Dictionary]:
	var ids := PackedStringArray()
	
	var dir := DirAccess.open("res://items/Inv_items")
	if dir:
		for file in dir.get_files():
			var item := load("res://items/Inv_items/" + file) as ItemData
			if item != null:
				ids.append(item.id)
	
	if ids.is_empty():
		ids = PackedStringArray(["(no items loaded)"])
	return [
		{
		"name": "item_id",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(ids)
		}
	]

func _get(property: StringName) -> Variant:
	if property == "item_id":
		return _item_id
	return null

func _set(property: StringName, value: Variant) -> bool:
	if property == "item_id":
		_item_id = value
		return true
	return false

func get_item_data() -> ItemData:
	if _item_id == "":
		return null
	return ItemRegistry.items.get(_item_id, null)

func take_damage(amount: float, _dmg_type: DamageTypes.DamageType = DamageTypes.DamageType.BASIC, _weapon_type: String = "Basic") -> void:
	AudioManager.play_sfx_2d("building_built", global_position)
	health -= amount * 0.4
	
	
	if health <= 0:
		destroy()

func destroy() -> void:
	
	main.drop_item(get_item_data(), global_position, 40)
	queue_free()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if preview_only: return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if main:
				main.show_build_item_tooltip(self)

func _process(_delta: float) -> void:
	if not GameManager or not "is_game_loaded" in GameManager:
		return
	if !GameManager.is_game_loaded: return
	if preview_only:
		$MouseInputMonitor.monitoring = false
	else:
		$MouseInputMonitor.monitoring = true
	
	var mouse_pos: Vector2 = get_global_mouse_position()
	
	if preview_only: return
	if mouse_pos.distance_to(global_position) <= cursor_proximity_dist:
		if anim_player.is_playing():
			return
		if !health_bar.visible:
			anim_player.play("show_bar")
	else:
		if anim_player.is_playing():
			return
		if health_bar.visible:
			anim_player.play("hide_bar")

func save_data() -> Dictionary:
	return {
		"scene_path": scene_file_path,
		"position": global_position,
	}

func load_data(data: Dictionary) -> void:
	global_position = data.get("position", Vector2(0, 0))
	
