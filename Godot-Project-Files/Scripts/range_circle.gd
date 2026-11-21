@tool
extends Node2D
class_name Circle

@export var radius: float = 50.0:
	get:
		return _radius
	set(value):
		_radius = value
		queue_redraw()
@export var color: Color = Color.WHITE:
	get:
		return _color
	set(value):
		_color = value
		queue_redraw()
@export var filled: bool = true:
	get:
		return _filled
	set(value):
		_filled = value
		queue_redraw()
@export var width: float = 1.0:
	get:
		return _width
	set(value):
		_width = value
		queue_redraw()

var _radius: float = 0.0
var _color: Color = Color.WHITE
var _filled: bool = true
var _width: float = -1.0

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color, filled, width)
