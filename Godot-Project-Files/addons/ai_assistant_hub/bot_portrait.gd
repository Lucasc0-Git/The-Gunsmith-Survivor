@tool
class_name BotPortrait
extends Control

signal think(value:bool)

const PORTRAITS_BASE := preload("res://addons/ai_assistant_hub/graphics/portraits/portraits_base.png")
const PORTRAIT_AMOUNT_X := 3
const PORTRAIT_AMOUNT_Y := 3
const SCALE := 3 # given the images are 16px but we are displaying them 48px, this is used to move the face when thinking

@onready var portrait_base: TextureRect = %PortraitBase
@onready var portrait_mouth: TextureRect = %PortraitMouth
@onready var portrait_eyes: TextureRect = %PortraitEyes
@onready var portrait_thinking: TextureRect = %PortraitThinking

var _think_tween:Tween
var _portrait_base_region:Rect2
var _portrait_mouth_region:Rect2
var _portrait_eyes_region:Rect2


func get_portrait_base_region() -> Rect2:
	return _portrait_base_region


func get_portrait_mouth_region() -> Rect2:
	return _portrait_mouth_region


func get_portrait_eyes_region() -> Rect2:
	return _portrait_eyes_region


func load_regions(portrait_base_region:Rect2, portrait_mouth_region:Rect2, portrait_eyes_region:Rect2) -> void:
	_portrait_base_region = portrait_base_region
	_portrait_mouth_region = portrait_mouth_region
	_portrait_eyes_region = portrait_eyes_region
	_select_region(portrait_base, _portrait_base_region)
	_select_region(portrait_mouth, _portrait_mouth_region)
	_select_region(portrait_eyes, _portrait_eyes_region)


func set_random() -> void:
	load_regions(_get_random_region(), _get_random_region(), _get_random_region())


func _get_random_region() -> Rect2:
	var x_rand := randi_range(0, PORTRAIT_AMOUNT_X - 1)
	var y_rand := randi_range(0, PORTRAIT_AMOUNT_Y - 1)
	return Rect2(x_rand*16,y_rand*16,16,16)


func _select_region(image:TextureRect, region:Rect2) -> void:
	var base_atlas: AtlasTexture = image.texture.duplicate()
	image.texture = base_atlas
	base_atlas.region = region


var is_thinking:= false:
	set(value):
		is_thinking = value
		if _think_tween != null and _think_tween.is_running():
			_think_tween.stop()
		portrait_thinking.visible = is_thinking
		think.emit(is_thinking)
		if is_thinking:
			portrait_eyes.position.x = SCALE
			portrait_eyes.position.y = -SCALE
			portrait_mouth.position = portrait_eyes.position
			_thinking_anim()
		else:
			portrait_eyes.position = Vector2.ZERO
			portrait_mouth.position = Vector2.ZERO
			self.rotation_degrees = 0


func _thinking_anim() -> void:
	while is_thinking:
		_think_tween = create_tween()
		_think_tween.tween_property(self, "rotation_degrees", -12, 1)
		_think_tween.tween_property(self, "rotation_degrees", 12, 1)
		await _think_tween.finished
	self.rotation_degrees = 0
	var complete = create_tween()
	complete.tween_property(self, "scale", Vector2(1.2, 1.2), 0.05)
	complete.tween_property(self, "scale", Vector2(1, 1), 0.05)
