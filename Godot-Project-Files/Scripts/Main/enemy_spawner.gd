extends Marker2D
class_name Spawner



func _ready() -> void:
	if OS.is_debug_build():
		visible = true
	else:
		visible = false
