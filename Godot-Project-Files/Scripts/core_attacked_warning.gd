extends Control

@export var decay_time: float = 5
@export var decay_timer: Timer

func _ready() -> void:
	decay_timer.start(decay_time)

func _on_decay_timer_timeout() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1)
	await tween.finished
	call_deferred("queue_free")
