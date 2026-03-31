extends Control
class_name UiBars

@onready var health_bar: ProgressBar = $TopBar/HealthBar

@export var health := 100


func _ready() -> void:
	pass


func health_changed(current: float, maximum: float) -> void:
	health_bar.value = (current / maximum) * 100
