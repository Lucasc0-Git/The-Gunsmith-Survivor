extends StaticBody2D
class_name TheCore

@onready var progress_bar: ProgressBar = $HealthBar

@export var max_health: float = 500

signal core_health_changed(health: float)

var main: Main

var health: float = 500:
	set(value):
		if value == health: return
		if value <= 0:
			main.game_over()
		health = value
		core_health_changed.emit(value)
		progress_bar.value = clamp(value, 0, max_health)

func _ready() -> void:
	progress_bar.max_value = max_health
	progress_bar.value = max_health

func take_damage(amount: float) -> void:
	print("thecore was damaged")
	health -= amount
