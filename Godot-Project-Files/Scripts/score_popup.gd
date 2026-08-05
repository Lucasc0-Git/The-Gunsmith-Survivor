extends Control
class_name ScorePopup

@onready var label: Label = $Label

func setup(text: String, color: Color = Color.WHITE) -> void:
	label.text = text
	label.modulate = color
	play_animation()

func play_animation() -> void:
	pivot_offset = size / 2
	
	var tween := create_tween().set_parallel(true)
	
	tween.tween_property(self, "position:y", position.y - 40, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(self, "scale", Vector2(1.0, 1.0), 0.65)
	
	tween.chain().tween_callback(queue_free)
