extends StaticBody2D
class_name TheCore

@onready var progress_bar: ProgressBar = $HealthBar

@export var max_health: float = 1500

signal player_entered_crafting_area()
signal player_exited_crafting_area()
signal core_health_changed(health: float)

var main: Main

var health: float = max_health:
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

func _on_crafting_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player_entered_crafting_area.emit()

func _on_crafting_area_body_exited(body: Node2D) -> void:
	if body is Player:
		player_exited_crafting_area.emit()
