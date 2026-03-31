extends Node2D
class_name BuildScene

@export var red_tint: Color = Color(1.0, 0.0, 0.0, 1.0)
@export var transparency: Color = Color(1.0, 1.0, 1.0, 0.565)
@export var main: Main

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = $HealthBar
